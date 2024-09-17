# Example Terraform Project

## Description

This project is an example of a Terraform project that creates a single VPC, subnet, and an EC2 instance in AWS. It demonstrates the standard file structure and configuration of a Terraform project.

## Files

The following files are contained in this project:

- `terraform.tf`: this houses the configuration of terraform itself. For this project it lists the required providers and their versions
- `providers.tf`: set provider specific configuration - in this case AWS parameters
- `main.tf`: Outlines all resources and data to be provisioned and managed by Terraform
- `variables.tf`: Defines the variables used in `main.tf` - it is like an argument list for a function
- `outputs.tf`: Defines the output values of the resources created by `main.tf` - it is like the return statement of a function
- `starting_values.auto.tfvars`: this file sets or overrides the default values of the variables passed into the `main.tf` module, rather than using the command line

The file breakdown conforms with the [Hashicorp Terraform Style Guide: File Names](https://developer.hashicorp.com/terraform/language/style#file-names) and [Variable Definitions (`.tfvars`) Files](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files)
