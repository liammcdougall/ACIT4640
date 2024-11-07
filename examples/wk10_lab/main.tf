module "vpc" {
  source       = "./modules/terraform_vpc_simple"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  subnet_cidr  = var.subnet_cidr
  aws_region   = var.aws_region
}

module "sg" {
  source       = "./modules/terraform_security_group"
  name         = "week10_sg"
  description  = "Allows ssh, web, and port 5000 ingress access and all egress"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc.id
  ingress_rules = [
    {
      description = "ssh access from home"
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_ipv4   = var.home_net
      rule_name   = "ssh_access_home"
    },
    {
      description = "ssh access from bcit"
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_ipv4   = var.bcit_net
      rule_name   = "ssh_access_bcit"
    },
    {
      description = "web access from home"
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_ipv4   = var.home_net
      rule_name   = "web_access_home"
    },
    {
      description = "web access from bcit"
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_ipv4   = var.bcit_net
      rule_name   = "web_access_bcit"
    },
    {
      description = "port 5000 access from home"
      ip_protocol = "tcp"
      from_port   = 5000
      to_port     = 5000
      cidr_ipv4   = var.home_net
      rule_name   = "port_5000_access_home"
    },
    {
      description = "port 5000 access from bcit"
      ip_protocol = "tcp"
      from_port   = 5000
      to_port     = 5000
      cidr_ipv4   = var.bcit_net
      rule_name   = "port_5000_access"
    }
  ]
  egress_rules = [
    {
      description = "allow all egress traffic"
      ip_protocol = "-1"
      from_port   = null
      to_port     = null
      cidr_ipv4   = "0.0.0.0/0"
      rule_name   = "allow_all_egress"
    }
  ]
}

module "ssh_key" {
  source       = "git::https://gitlab.com/acit_4640_library/tf_modules/aws_ssh_key_pair.git"
  ssh_key_name = var.ssh_key_name
  output_dir = "${path.root}"
}

module "ec2" {
  source = "./modules/terraform_ec2_multiple"
  instance_configs = {
    w1 = {
      ami_id         = var.ami_id
      type           = "t2.micro"
      subnet         = module.vpc.subnet.id
      security_group = module.sg.id
      private_ip     = "172.16.1.11"
      ssh_key_name   = module.ssh_key.ssh_key_name
      project_name   = var.project_name
      role           = "web"
    }
    w2 = {
      ami_id         = var.ami_id
      type           = "t2.micro"
      subnet         = module.vpc.subnet.id
      security_group = module.sg.id
      private_ip     = "172.16.1.12"
      ssh_key_name   = module.ssh_key.ssh_key_name
      project_name   = var.project_name
      role           = "web"
    },
    w3 = {
      subnet         = module.vpc.subnet.id
      role           = "backend"
      security_group = module.sg.id
      type           = "t2.micro"
      private_ip     = "172.16.1.13"
      aws_region     = var.aws_region
      ssh_key_name   = module.ssh_key.ssh_key_name
      project_name   = var.project_name
      ami_id         = var.ami_id
    },
    b1 = {
      ami_id         = var.ami_id
      type           = "t2.micro"
      subnet         = module.vpc.subnet.id
      security_group = module.sg.id
      private_ip     = "172.16.1.14"
      ssh_key_name   = module.ssh_key.ssh_key_name
      project_name   = var.project_name
      role           = "backend"
    }
  }

}

module "connect_script" {
  source = "git::https://gitlab.com/acit_4640_library/tf_modules/aws_ec2_connection_script.git"
  ec2_instances = module.ec2.instances
  output_file_path = "./connect_vars.sh"
  ssh_key_file = module.ssh_key.priv_key_file
  ssh_user_name = "ubuntu"
}