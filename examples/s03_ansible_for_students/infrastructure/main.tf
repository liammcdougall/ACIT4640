terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "us-west-2"
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "availability_zone" {
  description = "AWS availability zone"
  default     = "us-west-2a"
}
variable "project_name" {
  description = "Project name"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "192.168.0.0/16"
}

variable "subnet_cidr" {
  description = "Public Subnet CIDR block"
  default     = "192.168.2.0/24"
}

variable "default_route" {
  description = "Default route"
  default     = "0.0.0.0/0"
}

variable "home_net" {
  description = "Home network"
}

variable "bcit_net" {
  description = "BCIT network"
  default     = "142.232.0.0/16"

}

variable "ami_id" {
  description = "AMI ID"
  type       = string
}

variable "ssh_key_name" {
  description = "AWS SSH key name"
}

resource "aws_vpc" "exam_s03_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name    = "${var.project_name}_vpc"
    Project = var.project_name
  }
}

resource "aws_subnet" "exam_s03_sn" {
  vpc_id                  = aws_vpc.exam_s03_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.project_name}_subnet"
    Project = var.project_name
  }

}

resource "aws_internet_gateway" "exam_s03_ig" {
  vpc_id = aws_vpc.exam_s03_vpc.id

  tags = {
    Name    = "${var.project_name}_ig"
    Project = var.project_name
  }
}

resource "aws_route_table" "exam_s03_rt" {
  vpc_id = aws_vpc.exam_s03_vpc.id

  route {
    cidr_block = var.default_route
    gateway_id = aws_internet_gateway.exam_s03_ig.id
  }

  tags = {
    Name    = "${var.project_name}_rt"
    Project = var.project_name
  }
}

resource "aws_route_table_association" "exam_s03_rt_assoc" {
  subnet_id      = aws_subnet.exam_s03_sn.id
  route_table_id = aws_route_table.exam_s03_rt.id
}

resource "aws_security_group" "exam_s03_sg" {
  name        = "${var.project_name}_sg"
  description = "Allow ssh and port 9000 access from home and bcit"
  vpc_id      = aws_vpc.exam_s03_vpc.id
}

resource "aws_vpc_security_group_egress_rule" "exam_s03_egress_rule" {
  security_group_id = aws_security_group.exam_s03_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name    = "${var.project_name}_egress_rule"
    Project = var.project_name
  }
}


resource "aws_vpc_security_group_ingress_rule" "exam_s03_ingress_ssh_rule_bcit" {
  security_group_id = aws_security_group.exam_s03_sg.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.bcit_net
  tags = {
    Name    = "${var.project_name}_ingress_ssh_rule_bcit"
    Project = var.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "exam_s03_ingress_ssh_rule_home" {
  security_group_id = aws_security_group.exam_s03_sg.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.home_net
  tags = {
    Name    = "${var.project_name}_ingress_ssh_rule_home"
    Project = var.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "exam_s03_ingress_9k_rule_bcit" {
  security_group_id = aws_security_group.exam_s03_sg.id
  ip_protocol       = "tcp"
  from_port         = 9000
  to_port           = 9000
  cidr_ipv4         = var.bcit_net
  tags = {
    Name    = "${var.project_name}_ingress_9k_rule_bcit"
    Project = var.project_name
  }
}



resource "aws_vpc_security_group_ingress_rule" "exam_s03_ingress_9k_rule_home" {
  security_group_id = aws_security_group.exam_s03_sg.id
  ip_protocol       = "tcp"
  from_port         = 9000
  to_port           = 9000
  cidr_ipv4         = var.home_net
  tags = {
    Name    = "${var.project_name}_ingress_9k_rule_home"
    Project = var.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "exam_s03_ingress_vpc_internal" {
  security_group_id = aws_security_group.exam_s03_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = var.vpc_cidr
  tags = {
    Name    = "${var.project_name}_ingress_vpc_internal"
    Project = var.project_name
  }
}

resource "aws_instance" "chat_server" {
  ami             = var.ami_id
  instance_type   = "t2.micro"
  key_name        = var.ssh_key_name
  subnet_id       = aws_subnet.exam_s03_sn.id
  security_groups = [aws_security_group.exam_s03_sg.id]
  tags = {
    Name    = "chat_server"
    Project = var.project_name
    Type = "chat"
  }
}

resource "aws_instance" "generic" {
  ami             = var.ami_id
  instance_type   = "t2.micro"
  key_name        = var.ssh_key_name
  subnet_id       = aws_subnet.exam_s03_sn.id
  security_groups = [aws_security_group.exam_s03_sg.id]
  tags = {
    Name    = "generic"
    Project = var.project_name
    Type = "generic"
  }
}


output "chat_server_dns" {
  value = aws_instance.chat_server.public_dns
}

output "generic_dns" {
  value = aws_instance.generic.public_dns
}