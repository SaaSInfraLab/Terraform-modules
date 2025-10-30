// VPC resource
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = merge({ Name = "${var.name_prefix}-vpc" }, var.tags)
}
