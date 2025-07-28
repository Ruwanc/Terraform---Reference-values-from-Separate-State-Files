output "vpc_id" {
    value = module.vpc-module.aws_vpc_output #register this module output variable in vpc state file. then you will be able to pass this vpc id into subnet configuration using "terraform_remote_state" resource. value = module.<module name in main file in environment>.<output variable name mentioned in module outputs tf file>
}