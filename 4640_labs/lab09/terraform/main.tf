terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project = "${var.project_name}"
    }
  }

}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "ubuntu_ami_id" {
  description = "Ubuntu AMI ID"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "cidr_blocks" {
  description = "configuration attributes for CIDR blocks"
  type = map(object({
    address     = string
    cidr_bits   = number
    description = string
    subnet      = bool
    az          = optional(string)
    })
  )
}

variable "security_groups" {
  description = "configuration attributes for security groups"
  type = map(object({
    name        = string
    description = string
    egress_rules = list(object(
      {
        description          = string
        ip_protocol          = string
        from_port            = number
        to_port              = number
        ipv4_cidr_block_name = string
        rule_name            = string
      }
    ))
    ingress_rules = list(object(
      {
        description          = string
        ip_protocol          = string
        from_port            = number
        to_port              = number
        ipv4_cidr_block_name = string
        rule_name            = string
      }
    ))
    })
  )
}

variable "instance_configs" {
  description = "configuration attributes for ec2 instances"
  type = list(object({
    name           = string
    subnet         = string
    server_role    = string
    group          = string
    security_group = string
    type           = string
  }))
}

## ----------------------------------------------------------------------------
## CREATE A VPC 
## Also creates array of IPv4 octets for use in creating subnets
## ----------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr_blocks["vpc_cidr"].address}/${var.cidr_blocks["vpc_cidr"].cidr_bits}"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}_vpc"
  }
}


## ----------------------------------------------------------------------------
## CREATE VPC Networking
## ----------------------------------------------------------------------------
# Create a subnet for all of the cidr_blocks that have the subnet attribute set
resource "aws_subnet" "main" {
  for_each = {
    for key, config in var.cidr_blocks :
    key => config if config.subnet
  }

  vpc_id = aws_vpc.main.id

  cidr_block              = "${var.cidr_blocks[each.key].address}/${var.cidr_blocks[each.key].cidr_bits}"
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}_sn_${each.key}"
  }
}

resource "aws_internet_gateway" "main" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}_igw"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "${var.cidr_blocks["default"].address}/${var.cidr_blocks["default"].cidr_bits}"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.project_name}_rt"
  }
}

resource "aws_route_table_association" "main" {
  for_each = {
    for subnet in aws_subnet.main :
    subnet.tags.Name => subnet
  }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.main.id
}

## ----------------------------------------------------------------------------
## CONFIGURE VPC SECURITY 
## ----------------------------------------------------------------------------
resource "aws_security_group" "main" {
  for_each = {
    for key, config in var.security_groups :
    key => config
  }

  name        = "${var.project_name}_${each.key}"
  description = each.value.description
  vpc_id      = aws_vpc.main.id
  tags = {
    Name    = "${var.project_name}_${each.key}"
    Project = var.project_name
  }
}

locals {
  security_group_ingress = flatten([
    for key, config in var.security_groups :
    [
      for rule in config.ingress_rules :
      {
        security_group_id = aws_security_group.main[key].id
        rule_name         = rule.rule_name
        description       = rule.description
        ip_protocol       = rule.ip_protocol
        from_port         = rule.from_port
        to_port           = rule.to_port
        cidr_ipv4         = "${var.cidr_blocks[rule.ipv4_cidr_block_name].address}/${var.cidr_blocks[rule.ipv4_cidr_block_name].cidr_bits}"
      }
    ]
  ])

  security_group_egress = flatten([
    for key, config in var.security_groups :
    [
      for rule in config.egress_rules :
      {
        security_group_id = aws_security_group.main[key].id
        rule_name         = rule.rule_name
        description       = rule.description
        ip_protocol       = rule.ip_protocol
        from_port         = rule.from_port
        to_port           = rule.to_port
        cidr_ipv4         = "${var.cidr_blocks[rule.ipv4_cidr_block_name].address}/${var.cidr_blocks[rule.ipv4_cidr_block_name].cidr_bits}"
      }
    ]
  ])
}

resource "aws_vpc_security_group_ingress_rule" "main" {
  for_each = {
    for index, rule in local.security_group_ingress :
    rule.rule_name => rule
  }

  description       = each.value.description
  ip_protocol       = each.value.ip_protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_ipv4         = each.value.cidr_ipv4
  security_group_id = each.value.security_group_id
  tags = {
    Name    = "${var.project_name}_rule_${each.value.rule_name}"
    Project = var.project_name
  }
}

resource "aws_vpc_security_group_egress_rule" "main" {
  for_each = {
    for index, rule in local.security_group_egress :
    rule.rule_name => rule
  }

  description       = each.value.description
  ip_protocol       = each.value.ip_protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_ipv4         = each.value.cidr_ipv4
  security_group_id = each.value.security_group_id
  tags = {
    Name    = "${var.project_name}_rule_${each.value.rule_name}"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# Setup ssh key 
# -----------------------------------------------------------------------------
locals {
  ansible_dir = "${path.module}/../ansible"
}

resource "tls_private_key" "main" {
  algorithm = "ED25519"
  provisioner "local-exec" {
    command = <<DELIM
      echo '${tls_private_key.main.private_key_openssh}' > '${local.ansible_dir}/${var.project_name}.pem'
      echo '${tls_private_key.main.public_key_openssh}' > '${local.ansible_dir}/${var.project_name}.pub'
      chmod 400 ./'${local.ansible_dir}/${var.project_name}.pem'
    DELIM
    when    = create
  }
}

resource "terraform_data" "delete_key_pair" {
  input = {
    key_prefix = "${local.ansible_dir}/${var.project_name}"
  }
  provisioner "local-exec" {
    command = "rm -f \"${self.output.key_prefix}.pem\" \"${self.output.key_prefix}.pub\""
    when    = destroy
  }
}

resource "aws_key_pair" "main" {
  key_name   = var.project_name
  public_key = tls_private_key.main.public_key_openssh
}


## ----------------------------------------------------------------------------
## CONFIGURE EC2 INSTANCES
## ----------------------------------------------------------------------------
resource "aws_instance" "main" {
  count = length(var.instance_configs)

  # get random 0 or 1 from list based on the index of the instance
  # use it to select the AMI from the list of AMIs
  ami = var.ubuntu_ami_id

  instance_type   = var.instance_configs[count.index].type
  key_name        = aws_key_pair.main.key_name
  subnet_id       = aws_subnet.main[var.instance_configs[count.index].subnet].id
  security_groups = [aws_security_group.main[var.instance_configs[count.index].security_group].id]

  tags = {
    name    = "${var.instance_configs[count.index].name}"
    project = var.project_name
    server_role    = "${var.instance_configs[count.index].server_role}"
    group   = "${var.instance_configs[count.index].group}"
  }

  lifecycle {
    # prevent terraform from deleting and recreating the instance when managed by ansible
    ignore_changes = all
  }

}

## ----------------------------------------------------------------------------
## CONFIGURE BASH FILE WITH SSH CONNECTION VARIABLES
## Create script file to specify the ssh key and user for connecting
## to the ec2 instances, as well as short name assinged the public dns names of
## the instances 
## ----------------------------------------------------------------------------
resource "local_file" "connect_vars" {
  content  = <<-EOF
  private_key_file="${var.project_name}.pem"

  %{for instance in aws_instance.main~}
${instance.tags.name}="${instance.public_dns}"
alias ssh_${instance.tags.name}="ssh -i ${var.project_name}.pem -o StrictHostKeyChecking=no -o "UserKnownHostsFile=/dev/null" ubuntu@${instance.public_dns}"
  %{endfor~}


  EOF
  filename = abspath("${local.ansible_dir}/connect_vars.sh")
}

# Create Ansible Variables file for all hosts
# Specify the ssh key 
resource "local_file" "group_all_vars" {
  content = <<-EOF
  ---
  ansible_ssh_private_key_file: "${var.project_name}.pem"
  ansible_user: "ubuntu"
  remote_tmp: /tmp
  ...
  EOF

  filename = "${local.ansible_dir}/group_vars/all.yml"

}

output "ec2_instances" {
  description = "Name indexed Map of EC2 instance information that includes id, public IP, private IP, and DNS name"
  value = {
    for instance in aws_instance.main :
    instance.tags.name => {
      "id"         = instance.id
      "public_ip"  = instance.public_ip
      "private_ip" = instance.private_ip
      "dns_name"   = instance.public_dns
      "tags"       = instance.tags
    }
  }
}

output "ssh_priv_key_file" {
  description = "Absolute path to the private key file"
  value       = abspath("${var.project_name}.pub")
}

output "ssh_key_name" {
  description = "Name of the SSH key pair"
  value       = var.project_name
}

