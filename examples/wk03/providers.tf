# -----------------------------------------------------------------------------
# Configure the AWS provider 
# Language Reference: https://developer.hashicorp.com/terraform/language/providers
# AWS Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
# -----------------------------------------------------------------------------
provider "aws" {
  region = var.aws_region
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags-configuration-block
  default_tags {
    tags = {
      Project = "${var.project_name}"
    }
  }
}