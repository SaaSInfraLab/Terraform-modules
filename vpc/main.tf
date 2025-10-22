// Main VPC
locals {
  // map AZ => index to get deterministic ordering for for_each
  az_map = { for idx, az in var.azs : az => idx }
}

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = merge({ Name = "${var.name_prefix}-vpc" }, var.tags)
}

// Public subnets: one per AZ
resource "aws_subnet" "public" {
  for_each = local.az_map

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = merge({ Name = "${var.name_prefix}-public-${each.key}" }, var.tags)
}

// Private subnets: one per AZ
resource "aws_subnet" "private" {
  for_each = local.az_map

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value + length(var.azs))
  availability_zone = each.key

  tags = merge({ Name = "${var.name_prefix}-private-${each.key}" }, var.tags)
}

// Internet Gateway for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge({ Name = "${var.name_prefix}-igw" }, var.tags)
}

// Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.nat_gateway_count

  domain = "vpc"

  tags = merge({ Name = "${var.name_prefix}-nat-eip-${count.index}" }, var.tags)
}

// NAT Gateways (placed in the first N public subnets)
resource "aws_nat_gateway" "nat" {
  count = var.nat_gateway_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[var.azs[count.index]].id

  tags = merge({ Name = "${var.name_prefix}-nat-${count.index}" }, var.tags)
}

// Public route table -> IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge({ Name = "${var.name_prefix}-public-rt" }, var.tags)
}

// Associate public route table with public subnets
resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

// Private route tables (one per private subnet) -> NAT gateway
resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    # pick a NAT gateway based on AZ index
    nat_gateway_id = aws_nat_gateway.nat[local.az_map[each.key] % var.nat_gateway_count].id
  }

  tags = merge({ Name = "${var.name_prefix}-private-rt-${each.key}" }, var.tags)
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

// Security groups for EKS
resource "aws_security_group" "eks_cluster" {
  name        = "${var.name_prefix}-eks-cluster-sg"
  description = "Security group for EKS control plane"
  vpc_id      = aws_vpc.main.id

  # Note: ingress rules that reference another security group are created
  # below as separate aws_security_group_rule resources to avoid a circular
  # dependency between the two security groups.

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "${var.name_prefix}-eks-cluster-sg" }, var.tags)
}

resource "aws_security_group" "eks_nodes" {
  name        = "${var.name_prefix}-eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.main.id

  // Allow node to node communication
  ingress {
    description = "node to node"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  // Optional SSH access
  dynamic "ingress" {
    for_each = var.allow_ssh ? [1] : []
    content {
      description = "ssh"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.ssh_cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "${var.name_prefix}-eks-nodes-sg" }, var.tags)
}

// Security group rule: allow nodes -> cluster on ephemeral ports
resource "aws_security_group_rule" "cluster_from_nodes" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  description              = "Allow node to cluster communication"
}

// Security group rule: allow cluster -> nodes for Kubernetes API (443)
resource "aws_security_group_rule" "nodes_from_cluster" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
  description              = "Allow cluster API to nodes"
}

// CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/aws/vpc_flow_logs/${var.name_prefix}"
  retention_in_days = var.flow_log_retention_in_days

  tags = merge({ Name = "${var.name_prefix}-vpc-flow-logs" }, var.tags)
}

// IAM role for VPC Flow Logs to publish to CloudWatch Logs
resource "aws_iam_role" "vpc_flow_logs_role" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${var.name_prefix}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      }
    ]
  })

  tags = merge({ Name = "${var.name_prefix}-vpc-flow-logs-role" }, var.tags)
}

resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${var.name_prefix}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs_role[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"
      }
    ]
  })
}

// VPC Flow Log sending to CloudWatch Logs
resource "aws_flow_log" "vpc" {
  count = var.enable_flow_logs ? 1 : 0

  vpc_id               = aws_vpc.main.id
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  iam_role_arn         = aws_iam_role.vpc_flow_logs_role[0].arn
  traffic_type         = var.flow_log_traffic_type

  tags = merge({ Name = "${var.name_prefix}-vpc-flow-log" }, var.tags)
}
