locals {
    prefix = "${var.name_prefix}-${var.cluster_name}"
}

####################
# EKS: Cluster Role
####################
resource "aws_iam_role" "eks_cluster" {
    count = var.create_eks_cluster_role ? 1 : 0
    name = "${local.prefix}-cluster-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect    = "Allow"
                Principal = { Service = "eks.amazonaws.com" }
                Action    = "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
    count = var.create_eks_cluster_role ? 1 : 0
    role       = aws_iam_role.eks_cluster[0].name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Optional: attach VPC resource controller policy used by some EKS features (e.g. ENI config)
resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSVPCResourceController" {
    count = var.create_eks_cluster_role ? 1 : 0
    role       = aws_iam_role.eks_cluster[0].name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

####################
# EKS: Worker Node Role
####################
resource "aws_iam_role" "eks_node" {
    count = var.create_eks_node_role ? 1 : 0
    name = "${local.prefix}-node-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect    = "Allow"
                Principal = { Service = "ec2.amazonaws.com" }
                Action    = "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
    count = var.create_eks_node_role ? 1 : 0
    role       = aws_iam_role.eks_node[0].name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
    count = var.create_eks_node_role ? 1 : 0
    role       = aws_iam_role.eks_node[0].name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
    count = var.create_eks_node_role ? 1 : 0
    role       = aws_iam_role.eks_node[0].name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

####################
# VPC: Flow Logs role (to CloudWatch Logs)
####################
resource "aws_iam_role" "vpc_flow_logs" {
    count = var.create_vpc_flow_logs_role ? 1 : 0
    name = "${local.prefix}-vpc-flow-logs-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect    = "Allow"
                Principal = { Service = "vpc-flow-logs.amazonaws.com" }
                Action    = "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
    count = var.create_vpc_flow_logs_role ? 1 : 0
    name = "${local.prefix}-vpc-flow-logs-policy"
    role = aws_iam_role.vpc_flow_logs[0].id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents",
                    "logs:DescribeLogGroups",
                    "logs:DescribeLogStreams",
                    "logs:PutRetentionPolicy"
                ]
                Resource = "*"
            }
        ]
    })
}

####################
# Monitoring: CloudWatch Agent role (for EC2 / node instances)
####################
resource "aws_iam_role" "cloudwatch_agent" {
    count = var.create_cloudwatch_agent_role ? 1 : 0
    name = "${local.prefix}-cw-agent-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect    = "Allow"
                Principal = { Service = "ec2.amazonaws.com" }
                Action    = "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "cw_agent_CloudWatchAgentServerPolicy" {
    count = var.create_cloudwatch_agent_role ? 1 : 0
    role       = aws_iam_role.cloudwatch_agent[0].name
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

####################
# EKS: Cluster Access Roles (for users/CI/CD to access the cluster)
####################

# Admin Role - Full cluster admin access
resource "aws_iam_role" "eks_admin" {
    count = var.create_eks_access_roles && length(var.eks_admin_trusted_principals) > 0 ? 1 : 0
    name = "${local.prefix}-eks-admin-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    AWS = var.eks_admin_trusted_principals
                }
                Action = "sts:AssumeRole"
            }
        ]
    })

    tags = merge(var.tags, {
        Name = "${local.prefix}-eks-admin-role"
        Purpose = "EKS Cluster Admin Access"
    })
}

# Developer Role - Edit access (can create/update but not delete critical resources)
resource "aws_iam_role" "eks_developer" {
    count = var.create_eks_access_roles && length(var.eks_developer_trusted_principals) > 0 ? 1 : 0
    name = "${local.prefix}-eks-developer-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    AWS = var.eks_developer_trusted_principals
                }
                Action = "sts:AssumeRole"
            }
        ]
    })

    tags = merge(var.tags, {
        Name = "${local.prefix}-eks-developer-role"
        Purpose = "EKS Cluster Developer Access"
    })
}

# Viewer Role - Read-only access
resource "aws_iam_role" "eks_viewer" {
    count = var.create_eks_access_roles && length(var.eks_viewer_trusted_principals) > 0 ? 1 : 0
    name = "${local.prefix}-eks-viewer-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    AWS = var.eks_viewer_trusted_principals
                }
                Action = "sts:AssumeRole"
            }
        ]
    })

    tags = merge(var.tags, {
        Name = "${local.prefix}-eks-viewer-role"
        Purpose = "EKS Cluster Viewer Access"
    })
}