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
