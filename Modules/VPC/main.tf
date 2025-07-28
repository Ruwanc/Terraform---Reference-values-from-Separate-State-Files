#Create VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_range
  tags = {
    Name = "dev-project-vpc"
  }
}