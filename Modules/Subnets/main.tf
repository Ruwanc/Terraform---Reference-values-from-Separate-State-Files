
resource "aws_subnet" "public" {
  vpc_id     = var.project_vpc_id
  cidr_block = var.public_subnet_cidr_range
  tags = {
    Name = "dev-project-Public-Subnet-1"
  }
}
