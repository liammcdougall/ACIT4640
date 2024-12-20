terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

# get the most recent ami for Ubuntu 23.04
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-lunar-23.04-amd64-server-*"]
  }
}

# get the ssh key
data "aws_key_pair" "acit_4640_lab02_key" {
  key_name           = "acit_4640_lab02_key"
  include_public_key = true
}

# Create vpc
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "lab02_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "lab02_vpc"
  }
}

# create internet gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "lab02_igw" {
  vpc_id = aws_vpc.lab02_vpc.id
  tags = {
    Name = "lab02_igw"
  }
}

# create a route table
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "lab02_rt" {
  vpc_id = aws_vpc.lab02_vpc.id

  tags = {
    Name = "lab02_rt"
  }
}

# create aws route
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.lab02_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.lab02_igw.id
}

# associate route with subnets created below
resource "aws_route_table_association" "web" {
  subnet_id      = aws_subnet.lab02_sn_public.id
  route_table_id = aws_route_table.lab02_rt.id
}

resource "aws_route_table_association" "backend" {
  subnet_id      = aws_subnet.lab02_sn_private.id
  route_table_id = aws_route_table.lab02_rt.id
}

# subnets
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "lab02_sn_public" {
  vpc_id                  = aws_vpc.lab02_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "lab02_sn_public"
  }
}

resource "aws_subnet" "lab02_sn_private" {
  vpc_id                  = aws_vpc.lab02_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "lab02_sn_private"
  }
}

# security groups and rules
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "lab02_public" {
  name        = "lab02_public"
  description = "Public subnet accessible via web and ssh"
  vpc_id      = aws_vpc.lab02_vpc.id

  tags = {
    Name = "lab02_public"
  }
}

resource "aws_vpc_security_group_ingress_rule" "public-ssh" {
  security_group_id = aws_security_group.lab02_public.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "public-http" {
  security_group_id = aws_security_group.lab02_public.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "public-web-egress" {
  security_group_id = aws_security_group.lab02_public.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_vpc_security_group_egress_rule" "public-vpc-egress" {
  security_group_id = aws_security_group.lab02_public.id

  cidr_ipv4   = "10.0.0.0/16"
  ip_protocol = -1
}

# private security group and rules
resource "aws_security_group" "lab02_private" {
  name        = "lab02_private"
  description = "Private subnet accessible via ssh"
  vpc_id      = aws_vpc.lab02_vpc.id

  tags = {
    Name = "lab02_private"
  }
}
resource "aws_vpc_security_group_ingress_rule" "private-ssh" {
  security_group_id = aws_security_group.lab02_private.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "private-vpc-ingress" {
  security_group_id = aws_security_group.lab02_private.id

  cidr_ipv4   = "10.0.0.0/16"
  ip_protocol = -1
}

resource "aws_vpc_security_group_egress_rule" "private-web-egress" {
  security_group_id = aws_security_group.lab02_private.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_vpc_security_group_egress_rule" "private-vpc-egress" {
  security_group_id = aws_security_group.lab02_private.id

  cidr_ipv4   = "10.0.0.0/16"
  ip_protocol = -1
}

# create aws ec2 instances
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "lab02_web_w1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "acit_4640_lab02_key"

  security_groups = [aws_security_group.lab02_public.id]
  subnet_id       = aws_subnet.lab02_sn_public.id

  tags = {
    Name = "web_w1"
  }
}

resource "aws_instance" "lab02_backend_b1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "acit_4640_lab02_key"

  security_groups = [aws_security_group.lab02_private.id]
  subnet_id       = aws_subnet.lab02_sn_private.id

  tags = {
    Name = "backend_b1"
  }
}

output "web_dns" {
  value = aws_instance.lab02_web_w1.public_dns
}

output "backend_dns" {
  value = aws_instance.lab02_backend_b1.public_dns
}
