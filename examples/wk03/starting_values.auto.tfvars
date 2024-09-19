# This file contains the starting values for the variables in the main.tf file.
# by convention all files with the .auto.tfvars extension are automatically loaded by Terraform.
# Alternatively a file named the terraform.tfvars will be loaded in the same way.
ami_id       = "ami-0819177b8e6d4947a" # Ubuntu 2024.04 LTS x86-64 Image
project_name = "wk03_demo"
ssh_key_name = "wk03_demo_key"