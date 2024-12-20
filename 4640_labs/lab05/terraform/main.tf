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

# Create vpc
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "lab05_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "lab05_vpc"
  }
}

# create internet gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "lab05_igw" {
  vpc_id = aws_vpc.lab05_vpc.id
  tags = {
    Name = "lab05_igw"
  }
}

# create a route table
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "lab05_rt" {
  vpc_id = aws_vpc.lab05_vpc.id

  tags = {
    Name = "lab05_rt"
  }
}

# create aws route
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.lab05_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.lab05_igw.id
}

# associate route with subnets created below
resource "aws_route_table_association" "web" {
  subnet_id      = aws_subnet.lab05_sn_public.id
  route_table_id = aws_route_table.lab05_rt.id
}

resource "aws_route_table_association" "backend" {
  subnet_id      = aws_subnet.lab05_sn_private.id
  route_table_id = aws_route_table.lab05_rt.id
}

# subnets
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "lab05_sn_public" {
  vpc_id                  = aws_vpc.lab05_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "lab05_sn_public"
  }
}

resource "aws_subnet" "lab05_sn_private" {
  vpc_id                  = aws_vpc.lab05_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "lab05_sn_private"
  }
}

# security groups and rules
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "lab05_public" {
  name        = "lab05_public"
  description = "Public subnet accessible via web and ssh"
  vpc_id      = aws_vpc.lab05_vpc.id

  tags = {
    Name = "lab05_public"
  }
}

resource "aws_vpc_security_group_ingress_rule" "public-ssh" {
  security_group_id = aws_security_group.lab05_public.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "public-http" {
  security_group_id = aws_security_group.lab05_public.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "public-web-egress" {
  security_group_id = aws_security_group.lab05_public.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_vpc_security_group_egress_rule" "public-vpc-egress" {
  security_group_id = aws_security_group.lab05_public.id

  cidr_ipv4   = "10.0.0.0/16"
  ip_protocol = -1
}

# private security group and rules
resource "aws_security_group" "lab05_private" {
  name        = "lab05_private"
  description = "Private subnet accessible via ssh"
  vpc_id      = aws_vpc.lab05_vpc.id

  tags = {
    Name = "lab05_private"
  }
}
resource "aws_vpc_security_group_ingress_rule" "private-ssh" {
  security_group_id = aws_security_group.lab05_private.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "private-vpc-ingress" {
  security_group_id = aws_security_group.lab05_private.id

  cidr_ipv4   = "10.0.0.0/16"
  ip_protocol = -1
}

resource "aws_vpc_security_group_egress_rule" "private-web-egress" {
  security_group_id = aws_security_group.lab05_private.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_vpc_security_group_egress_rule" "private-vpc-egress" {
  security_group_id = aws_security_group.lab05_private.id

  cidr_ipv4   = "10.0.0.0/16"
  ip_protocol = -1
}

# create aws ec2 instances
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "lab05_web_w1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "acit_4640_lab05_key"

  security_groups = [aws_security_group.lab05_public.id]
  subnet_id       = aws_subnet.lab05_sn_public.id

  tags = {
    Name = "web_w1"
  }
}

resource "aws_instance" "lab05_backend_b1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "acit_4640_lab05_key"

  security_groups = [aws_security_group.lab05_private.id]
  subnet_id       = aws_subnet.lab05_sn_private.id

  tags = {
    Name = "backend_b1"
  }
}

output "web_dns" {
  value = aws_instance.lab05_web_w1.public_dns
}

output "backend_dns" {
  value = aws_instance.lab05_backend_b1.public_dns
}

output "web_ip" {
  value = aws_instance.lab05_web_w1.public_ip
}

output "backend_ip" {
  value = aws_instance.lab05_backend_b1.public_ip
}


