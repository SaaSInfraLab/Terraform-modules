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
