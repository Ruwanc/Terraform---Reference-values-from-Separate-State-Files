module "subnet" {
    source = "../../../Modules/Subnets"
    public_subnet_cidr_range = "10.1.1.0/24"
    project_vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
}