
module "vpc-module" {
  source = "../../../Modules/VPC"
#   module_environment       = var.prod_environment
#   module_project_name      = var.prod_project_name
  vpc_cidr_range           = var.prod_vpc_cidr_range
#   public_subnet_cidr_range = var.prod_public_subnet_cidr_range
}

module "vpc-module" {
  source = "../../../Modules/VPC"
  vpc_cidr_range           = var.prod_vpc_cidr_range
}