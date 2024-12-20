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

