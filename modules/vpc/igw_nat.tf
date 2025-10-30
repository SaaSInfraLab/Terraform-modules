// Internet Gateway for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge({ Name = "${var.name_prefix}-igw" }, var.tags)
}

// Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  for_each = { for idx in range(var.nat_gateway_count) : var.azs[idx] => idx }

  domain = "vpc"

  tags = merge({ Name = "${var.name_prefix}-nat-eip-${each.value}" }, var.tags)
}

// NAT Gateways (placed in the first N public subnets)
resource "aws_nat_gateway" "nat" {
  for_each = { for idx in range(var.nat_gateway_count) : var.azs[idx] => idx }

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge({ Name = "${var.name_prefix}-nat-${each.value}" }, var.tags)
}
