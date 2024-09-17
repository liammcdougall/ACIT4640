# -----------------------------------------------------------------------------
# Configure Terraform 
# Reference: https://developer.hashicorp.com/terraform/language/settings
# Most importantly identify the required providers
# -----------------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      # Used to provision resources in AWS
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      # Used to generate local files - like ssh keys
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    tls = {
      # Used to generate ssh keys 
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
