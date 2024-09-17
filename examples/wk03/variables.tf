variable "ami_id" {
  type        = string
  default     = "ami-0819177b8e6d4947a"
  description = "The AMI ID for use by ec2 instances in project"
}
variable "availability_zone" {
  type        = string
  default     = "us-west-2a"
  description = "The availability zone for the project"
}

variable "aws_region" {
  type        = string
  default     = "us-west-2"
  description = "The AWS region"
}

variable "base_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The base cider block for the VPC"
}

variable "project_name" {
  type        = string
  description = "The name of the project"
}

variable "ssh_key_name" {
  type        = string
  default     = "temp_ssh_key"
  description = "The name of the ssh key"
}

variable "subnet_cidr_block" {
  type        = string
  default     = "10.0.1.0/24"
  description = "The base cider block for the VPC"
}



