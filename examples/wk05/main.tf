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

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "cidr_blocks" {
  description = "configuration attributes for CIDR blocks"
  type = map(object({
    address = string
    cidr_bits  = number
    description = string
    subnet = bool
    az = optional(string)
    })
  )
}

variable "ssh_key_name" {
  description = "AWS SSH key name"
  default     = "acit_4640_202430"
  type        = string
}

variable "security_groups" {
  description = "configuration attributes for security groups"
  type = map(object({
    name        = string
    description = string
    egress_rules = list(object(
      {
        description = string
        ip_protocol = string
        from_port   = number
        to_port     = number
        ipv4_cidr_block_name = string
        rule_name   = string
      }
    ))
    ingress_rules = list(object(
      {
        description = string
        ip_protocol = string
        from_port   = number
        to_port     = number
        ipv4_cidr_block_name = string
        rule_name   = string
      }
    ))
  })
  )
}

variable "instance_configs" {
  description = "configuration attributes for ec2 instances"
  type = map(object({
    subnet = string
    role   = string
    security_group = string
    type   = string
    private_ip = string
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
    Name    = "${var.project_name}_vpc"
    Project = var.project_name
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
    Name    = "${var.project_name}_sn_${each.key}"
    Project = var.project_name
  }
}

resource "aws_internet_gateway" "main" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}_igw"
    Project = var.project_name
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {

    cidr_block = "${var.cidr_blocks["default"].address}/${var.cidr_blocks["default"].cidr_bits}"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}_rt"
    Project = var.project_name
  }
}

# Associate the route table with all of the subnets
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
# create security groups from list of security group configurations
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


# create security group ingress and egress rules from list of security group configurations
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
resource "tls_private_key" "main" {
  # Reference: https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
  algorithm = "ED25519"

  # Generate key-pair files in current directory when creating the key pair
  # For use when SSHing to the EC2 instances
  provisioner "local-exec" {
    # Reference: https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec
    # Tutorial: https://spacelift.io/blog/terraform-provisioners
    # Using a terraform variable in shell https://stackoverflow.com/questions/71178041/how-to-insert-terraform-variable-in-shell-script
    command = <<DELIM
      echo '${tls_private_key.main.private_key_openssh}' > '${var.ssh_key_name}.pem'
      echo '${tls_private_key.main.public_key_openssh}' > '${var.ssh_key_name}.pub'
      chmod 400 ./'${var.ssh_key_name}.pem'
    DELIM

    when = create
  }
}

# Create a data source  that will be used to delete the key pair files when the
# infrastructure is destroyed. This avoids polluting the local filesystem with
# key files
resource "terraform_data" "delete_key_pair" {
  # Reference: https://developer.hashicorp.com/terraform/language/resources/terraform-data
  # Input stores value that is accessed in the provisioner block as output
  input = {
    key_name = var.ssh_key_name
  }
  # Delete the locally created key files on destroy
  provisioner "local-exec" {
    # Reference: https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec
    command = "rm -f \"${self.output.key_name}.pem\" \"${self.output.key_name}.pub\""
    when    = destroy
  }
}

# Sync SSH public key with AWS
resource "aws_key_pair" "main" {
  # Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
  key_name   = "${var.ssh_key_name}"
  public_key = tls_private_key.main.public_key_openssh
}


## ----------------------------------------------------------------------------
## CONFIGURE EC2 INSTANCES
## Create one ec2 instance of each role on each subnet
## ----------------------------------------------------------------------------
resource "aws_instance" "main" {
  for_each = {
    for key, config in var.instance_configs :
    key => config
  }

  ami             = var.ami_id
  instance_type   = each.value.type
  key_name        = "${var.ssh_key_name}"
  subnet_id       = aws_subnet.main[each.value.subnet].id
  security_groups = [aws_security_group.main[each.value.security_group].id]
  private_ip      = "${each.value.private_ip}"

  tags = {
    Name        = "${var.project_name}_${each.value.role}_${each.key}"
    Project     = var.project_name
    Role = "${each.value.role}"
  }

  lifecycle {
    # prevent terraform from deleting and recreating the instance when managed by ansible
    ignore_changes = all
  }

}

## ----------------------------------------------------------------------------
## CONFIGURE ANSIBLE
## Create Ansible variable file to specify the ssh key and user for connecting
## to the ec2 instances 
## ----------------------------------------------------------------------------
resource "local_file" "inventory_vars" {
  content  = <<-EOF
  project_${var.project_name}:
    vars:
      ansible_ssh_private_key_file: "${path.module}/${var.ssh_key_name}.pem"
      ansible_user: "ubuntu"
  EOF
  filename = abspath("${path.root}/terraform_vars.yml")
}

## ----------------------------------------------------------------------------
## CONFIGURE BASH FILE WITH SSH CONNECTION VARIABLES
## Create script file to specify the ssh key and user for connecting
## to the ec2 instances, as well as short name assinged the public dns names of
## the instances 
## ----------------------------------------------------------------------------
resource "local_file" "connect_vars" {
  # split the name of the instance into pieces based on delimeter "_"
  # and get the last component.
  # i.e. the name of instance without the project and role
  # then use it as the bash variable name that is assigned the public dns name 
  content  = <<-EOF
  private_key_file="${var.ssh_key_name}.pem"
  ansible_user="ubuntu"

  %{for instance in aws_instance.main~}
${reverse(split("_", instance.tags.Name))[0]}="${instance.public_dns}"
  %{endfor~}
  EOF
  filename = abspath("${path.root}/connect_vars.sh")
}

# -----------------------------------------------------------------------------
# Generate inventory for use Ansible
# Ansible Inventory: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
# -----------------------------------------------------------------------------
# Local varialbles to used to build Ansible inventory file

locals {
  # String Templates: https://developer.hashicorp.com/terraform/language/expressions/strings#string-templates
  # Substring: https://developer.hashicorp.com/terraform/language/functions/substr
  # The projecet name is trimmed from the instance name to get the server alias for the inventory file
  # this is to make adhoc ansible commands easier to run
  prefix_length = length(var.project_name) + 1

  # Create a string for each server type that stores the server alias 
  # and public dns for each server this will be when writing the inventory file
  web_servers = <<-EOT
  %{for instance in aws_instance.main~}
    %{if instance.tags["Role"] == "web"}
      ${substr(instance.tags["Name"], local.prefix_length, -1)}:
        ansible_host: ${instance.public_dns}
    %{endif}
  %{endfor~}
  EOT

  backend_servers = <<-EOT
  %{for instance in aws_instance.main~}
    %{if instance.tags["Role"] == "backend"}
      ${substr(instance.tags["Name"], local.prefix_length, -1)}:
        ansible_host: ${instance.public_dns}
    %{endif}
  %{endfor~}
  EOT
}

# Create Ansible Inventory file
# Specify the ssh key and user and the servers for each server type
resource "local_file" "inventory" {
  # File Reference: https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
  content = <<-EOF
  all:
    vars:
      ansible_ssh_private_key_file: "${path.module}/${var.ssh_key_name}.pem"
      ansible_user: ubuntu
  web:
    hosts:
      ${local.web_servers}
  backend:
    hosts:
      ${local.backend_servers}
  EOF

  filename = "${path.module}/hosts.yml"

}

output "subnets" {
  description = "A name indexed map of subnet information including id, CIDR, and availability zone"
  value = { 
    for subnet in aws_subnet.main: 
      subnet.tags.Name => {
        "id" = subnet.id
        "cidr" = subnet.cidr_block
      }
   }
}

output "ec2_instances" {
  description = "Name indexed Map of EC2 instance information that includes id, public IP, private IP, and DNS name"
  value = {
    for instance in aws_instance.main: 
        instance.tags.Name => {
          "id" = instance.id
          "public_ip" = instance.public_ip
          "private_ip" = instance.private_ip
          "dns_name" = instance.public_dns
          "tags" = instance.tags
      }
  }
}

output "ssh_pub_key_file" {
  description = "Absolute path to the public key file"
  value = abspath("${var.ssh_key_name}.pub")
}

output "ssh_priv_key_file" {
  description = "Absolute path to the private key file"
  value = abspath("${var.ssh_key_name}.pub")
}

output "ssh_key_name" {
  description = "Name of the SSH key pair"
  value = "${var.ssh_key_name}"
}