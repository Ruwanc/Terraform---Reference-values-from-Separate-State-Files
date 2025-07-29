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