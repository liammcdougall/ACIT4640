# -----------------------------------------------------------------------------
# Configure AWS VPC with a single subnet, internet gateway, route table, and
# security group. Create an EC2 instance in the subnet with a public IP address
#
# Terraform Configuration Tutorial: https://developer.hashicorp.com/terraform/tutorials/configuration-language
# Terraform Language Reference: https://developer.hashicorp.com/terraform/language
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Configure Terraform Settings
# https://developer.hashicorp.com/terraform/language/settings
# -----------------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Define variables for use in main terraform module (aka this file)
# Reference: https://developer.hashicorp.com/terraform/language/values/locals
# Tutorial: https://developer.hashicorp.com/terraform/tutorials/configuration-language/locals
# -----------------------------------------------------------------------------
locals {
  base_cidr_block   = "10.0.0.0/16"
  subnet_cidr_block = "10.0.1.0/24"
  project_name      = "acit4640_wk02"
  availability_zone = "us-west-2a"
  ssh_key_name      = "acit4640_wk02"
}

# -----------------------------------------------------------------------------
# Configure the AWS provider 
# Language Reference: https://developer.hashicorp.com/terraform/language/providers
# AWS Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
# -----------------------------------------------------------------------------
provider "aws" {
  region = "us-west-2"
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags-configuration-block
  default_tags {
    tags = {
      Project = "${local.project_name}"
    }
  }
}

# -----------------------------------------------------------------------------
# Setup the network infrastructure: VPC, subnet, internet gateway, route table
# Tutorial: https://developer.hashicorp.com/terraform/tutorials/configuration-language/resource
# -----------------------------------------------------------------------------


resource "aws_vpc" "main" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
  cidr_block           = local.base_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "${local.project_name}_vpc"
  }
}

resource "aws_subnet" "main" {
  # Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.subnet_cidr_block
  availability_zone       = local.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.project_name}_main_subnet"
  }
}

resource "aws_internet_gateway" "main" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway 
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${local.project_name}_main_igw"
  }
}

resource "aws_route_table" "main" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${local.project_name}_main_rt"
  }
}

resource "aws_route" "default_route" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route 
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "main" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# -----------------------------------------------------------------------------
# Setup the security group and rules
# -----------------------------------------------------------------------------

resource "aws_security_group" "main" {
  # https://registry.terraform.io/providers/-/aws/latest/docs/resources/security_group
  name        = "${local.project_name}_main_sg"
  description = "allow all outbound traffic and ssh and http in from everywhere"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "${local.project_name}_main_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "main" {
  # https://registry.terraform.io/providers/-/aws/latest/docs/resources/vpc_security_group_egress_rule
  # make this open to everything from everywhere
  description       = "allow all outbound traffic"
  security_group_id = aws_security_group.main.id
  ip_protocol       = "-1" # this matches all protocols
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    name = "${local.project_name}_main_egress_rule"
  }

}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  # https://registry.terraform.io/providers/-/aws/latest/docs/resources/vpc_security_group_ingress_rule 
  # ssh and http in from everywhere
  description       = "allow ssh from everywhere"
  security_group_id = aws_security_group.main.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    name = "${local.project_name}_ssh_ingress_rule"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  description       = "allow http from everywhere"
  security_group_id = aws_security_group.main.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    name = "${local.project_name}_http_ingress_rule"
  }
}

# -----------------------------------------------------------------------------
# Setup ssh keys 
# -----------------------------------------------------------------------------
# Generate local ssh key pair 
resource "terraform_data" "ssh_key_pair" {
  # https://developer.hashicorp.com/terraform/language/resources/terraform-data

  # This stores the path to the private key 
  input = "${path.module}/${local.ssh_key_name}.pem"

  provisioner "local-exec" {
    # https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec
    command = "ssh-keygen -C \"${local.ssh_key_name}\" -f \"${path.module}/${local.ssh_key_name}.pem\" -m PEM -t ed25519 -N ''"
    
    # https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax#creation-time-provisioners
    when    = create
  }

  provisioner "local-exec" {
    # glob expressions don't work - need to delete each file individually
    command = "rm -f \"${self.output}\" \"${self.output}.pub\""

    # https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax#destroy-time-provisioners
    when = destroy

  }
}

# -----------------------------------------------------------------------------
# Get local ssh key pair file
# -----------------------------------------------------------------------------
# Get the public key from a local file which is assumed to be in the same
# directory as the terraform file
data "local_file" "ssh_pub_key" {
# https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file
# https://developer.hashicorp.com/terraform/language/expressions/references#filesystem-and-workspace-info
  filename = "${path.module}/${local.ssh_key_name}.pem.pub"

  # depends_on is used to ensure that the local key reading the local file
  depends_on = [terraform_data.ssh_key_pair]

}

# -----------------------------------------------------------------------------
# Create AWS key from local key file
# -----------------------------------------------------------------------------
# The resource below assumes that we have created a local key pair but
# haven't imported it to AWS yet. From the docs: 
# "Currently this resource requires an existing user-supplied key pair. 
# This key pair's public key will be registered with AWS to allow logging-in to
# EC2 instances." 
resource "aws_key_pair" "ssh_key_pair" {
# https://registry.terraform.io/providers/-/aws/latest/docs/resources/key_pair
  key_name   = local.ssh_key_name
  public_key = data.local_file.ssh_pub_key.content

  # depends_on is used to ensure that the local key is created before the AWS
  # key pair is "imported"
  # https://developer.hashicorp.com/terraform/language/meta-arguments/depends_on
  depends_on = [terraform_data.ssh_key_pair]
}

# -----------------------------------------------------------------------------
# Get the most recent ami for Ubuntu 22.04
# -----------------------------------------------------------------------------
data "aws_ami" "ubuntu" {
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
  most_recent = true
  # this is the owner id for Canonical - the publisher of Ubuntu
  owners = ["099720109477"]

  filter {
    name = "name"
    # This is a glob expression - the * is a wildcard - that matches  the most
    # recent Ubuntu 23.04 image x86 64-bit server image
    values = ["ubuntu/images/hvm-ssd/ubuntu-lunar-23.04-amd64-server-*"]
  }
}

# -----------------------------------------------------------------------------
# Create and run the EC2 instance 
# -----------------------------------------------------------------------------
resource "aws_instance" "ubuntu" {
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
  instance_type = "t2.micro"
  ami           = data.aws_ami.ubuntu.id

  key_name               = local.ssh_key_name
  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = aws_subnet.main.id
  user_data              = file("${path.module}/ec2_host_setup.sh")

  tags = {
    Name = "${local.project_name}_ubuntu_server"
  }

}

# -----------------------------------------------------------------------------
# Define module outputs - these output to the command line for main module
#
# https://developer.hashicorp.com/terraform/language/values/outputs
# https://developer.hashicorp.com/terraform/tutorials/configuration-language/outputs  
# -----------------------------------------------------------------------------

# output public ip address of the instance
output "instance_public_ip" {
  value = aws_instance.ubuntu.public_ip
}

# output public dns name of the instance
output "instance_dns" {
  value = aws_instance.ubuntu.public_dns
}

