# How to use Modules with Separate State Files for Terraform Resources and how to reference values from other State Files

## Introduction

Terraform is an Infrastructure as Code (IaC) tool. With the help of this valuable tool you can create, update your infrastructure as well as you will be able to safely version your infrastructure. You can also delete all the resources you have built using this tool. This tool is a well-known tool among DevOps and CloudOps Engineers.

Let’s see how we can use this tool to provision an AWS VPC and a Subnet. Actually the scope of this article is to Create Terraform resources using modules and keep the resource details within separate State Files.

## What is a “State File” in terraform?
Simply a terraform state file is the most important file when you use Terraform to create resources. When you provision a VM in AWS (or in any other cloud provider or when using any other supported provider to provision infrastructure), terraform will save the details of the created VM inside this State File. This State File will be created automatically by Terraform.

## What is a “Module” in terraform?
A module is a reusable code base in terraform which follows the DRY (Don’t Repeat Yourself) principle. Once you create a Module for a resource, you can re-use it any time you want. Further, this is one of the best practices you should follow.

As I mentioned earlier, we are going to use separate terraform state files for each resource (VPC and Subnet). We can store all the required details of resources created by Terraform in a single State File. There is a risk of using a single state file for all terraform resources. If the state file is somehow corrupted and all the details related to provisioned infrastructure will vanish and you may have to face so many troubles. 

It is terraform best practice to use separate terraform state files for separate resources. As an example one state file for VMs, another state file for database instances.

Then let's see how we can use terraform modules with separate state files and most importantly how to reference values between resources.

Our project's file architecture will be as below.

```
ProjectRoot/
├── Modules/
│   ├── VPC/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── Subnets/
│       ├── main.tf
│       └── variables.tf
│
└── Environments/
    └── Dev/
        ├── vpc/
        │   ├── main.tf
        │   ├── variables.tf
        │   ├── outputs.tf
        │   └── providers.tf
        │
        └── subnets/
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
            ├── providers.tf
            └── data.tf
```

### 1. Create the VPC module.
Add main.tf, variables.tf and outputs.tf files under the VPC folder which is a subfolder of the Modules folder.

Add below configurations to the main.tf file.

```
resource "aws_vpc" "this" {
 cidr_block = var.vpc_cidr_range
 tags = {
   Name = "dev-project-vpc"
 }
}
```

Add below configurations to variables.tf file.

```
variable "vpc_cidr_range" {
   description = "CIDR range for the VPC"
   type        = string
   default     =  "10.0.0.0/16"
}
```

Add below configurations to outputs.tf file. This is a very important configuration. Because of this variable you will be able to pass the “VPC id” into the subnet resource.

```
output "aws_vpc_output" {
   value = aws_vpc.this.id
}
```

### 2. Create Subnets module
	
Add main.tf , variables.tf files under the Subnets directory.
	
Add below configurations to the main.tf file.
	
```	
resource "aws_subnet" "public" {
 vpc_id     = var.project_vpc_id
 cidr_block = var.public_subnet_cidr_range
 tags = {
   Name = "dev-project-Public-Subnet-1"
 }
}
```
Add below configurations to the variables.tf file.

```	
variable "public_subnet_cidr_range" { type = string }

variable "project_vpc_id" {
 type = string
}
```

### 3. Now switch to the “VPC” folder under the “Environments -> Dev” directory. You need to create  main.tf, variables.tf, outputs.tf and providers.tf files inside the “vpc” directory.

Add below configurations to main.tf file.

```
module "vpc-module" {
 source = "../../../Modules/VPC"
 vpc_cidr_range           = var.prod_vpc_cidr_range
}
```

Add below configurations to variables.tf file.

```
variable "prod_vpc_cidr_range" {
   type = string
   default = "10.1.0.0/16"
}
```
Update the outputs.tf file using below configurations. With the help of this output variable you will be able to register the module output variable value with the state file of VPC.

```
output "vpc_id" {
   value = module.vpc-module.aws_vpc_output #register this module output variable in vpc state file. then you will be able to pass this vpc id into subnet configuration using "terraform_remote_state" resource. value = module.<module name in main file in environment>.<output variable name mentioned in module outputs tf file>
}
```

Apply below changes to the providers.tf file.

```
terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 6.0"
   }
 }
}

# Configure the AWS Provider
provider "aws" {
 region = "ap-south-1"
}
```
### 4. Now create the main.tf, outputs.tf, providers.tf and data.tf files under “subnets directory inside “Environment/Dev” directory.

Update the empty main.tf file with below config.

```
module "subnet" {
   source = "../../../Modules/Subnets"
   public_subnet_cidr_range = "10.1.1.0/24"
   project_vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
}
```

Update the data.tf file with the below.

```
data "terraform_remote_state" "vpc" {
   backend = "local"
   config = {
       path = "../vpc/terraform.tfstate"
   }
}
```


Add below configurations to outputs.tf file. Using this output variable you will be able to view which data will be exposed from the imported “terraform_remote_state” resource defined in the data.tf file. If not required you can comment out the content of this output variable in outputs.tf file.

```
output "test" {
   value = data.terraform_remote_state.vpc
}
```

Add below contents to providers.tf file.

```
terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 6.0"
   }
 }
}

# Configure the AWS Provider
provider "aws" {
 region = "ap-south-1"
}
```

Now the configuration part is done.

Let’s see how we can provision these resources into AWS.

Open the terminal at the path below first.

ProjectRoot/Environments/vpc

Executes the below commands.
``` 
    terraform init
    terraform apply 
```

Again switch to the below path in terminal and execute below commands.

``` 
    terraform init
    terraform apply 
```

Now you will be able to create the VPC and Subnet successfully.

Note:
- You should have basic understanding in terraform.
- This article is for learning purposes only and the main consideration is to understand how to reference values between modules when using separate state files.
- Do not use this code for the production environment since this needs more improvements before being production-ready
