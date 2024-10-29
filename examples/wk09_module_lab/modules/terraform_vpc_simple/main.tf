provider "aws" {
  region = var.aws_region
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "vpc_1" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name    = "vpc_1"
    Project = var.project_name
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "sn_1" {
  vpc_id                  = aws_vpc.vpc_1.id
  cidr_block              = var.subnet_cidr
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "sn_1"
    Project = var.project_name
  }

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "gw_1" {
  vpc_id = aws_vpc.vpc_1.id

  tags = {
    Name    = "gw_1"
    Project = var.project_name
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "rt_1" {
  vpc_id = aws_vpc.vpc_1.id

  route {
    cidr_block = var.default_route
    gateway_id = aws_internet_gateway.gw_1.id
  }

  tags = {
    Name    = "rt_1"
    Project = var.project_name
  }
}

resource "aws_route_table_association" "web_rt_assoc_1" {
  subnet_id      = aws_subnet.sn_1.id
  route_table_id = aws_route_table.rt_1.id
}

resource "aws_security_group" "sg_1" {
  name        = "sg_1"
  description = "Allow http,ssh, port 5000 access to ec2 from home and bcit"
  vpc_id      = aws_vpc.vpc_1.id
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_vpc_security_group_egress_rule" "egress_rule" {
  security_group_id = aws_security_group.sg_1.id
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name    = "egress_rule"
    Project = var.project_name
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_vpc_security_group_ingress_rule" "ssh_home_rule" {
  security_group_id = aws_security_group.sg_1.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.home_net
  tags = {
    Name    = "ssh_home_rule"
    Project = var.project_name
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_vpc_security_group_ingress_rule" "ssh_bcit_rule" {
  security_group_id = aws_security_group.sg_1.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.bcit_net
  tags = {
    Name    = "ssh_bcit_rule"
    Project = var.project_name
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_vpc_security_group_ingress_rule" "http_home_rule" {
  security_group_id = aws_security_group.sg_1.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = var.home_net
  tags = {
    Name    = "http_home_rule"
    Project = var.project_name
  }
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_vpc_security_group_ingress_rule" "http_bcit_rule" {
  security_group_id = aws_security_group.sg_1.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = var.bcit_net
  tags = {
    Name    = "http_bcit_rule"
    Project = var.project_name
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_vpc_security_group_ingress_rule" "nc_home_rule" {
  security_group_id = aws_security_group.sg_1.id
  ip_protocol       = "tcp"
  from_port         = 5000
  to_port           = 5000
  cidr_ipv4         = var.home_net
  tags = {
    Name    = "nc_home_rule"
    Project = var.project_name
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_vpc_security_group_ingress_rule" "nc_bcit_rule" {
  security_group_id = aws_security_group.sg_1.id
  ip_protocol       = "tcp"
  from_port         = 5000 
  to_port           = 5000 
  cidr_ipv4         = var.bcit_net
  tags = {
    Name    = "nc_bcit_rule"
    Project = var.project_name
  }
}

