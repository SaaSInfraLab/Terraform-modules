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
