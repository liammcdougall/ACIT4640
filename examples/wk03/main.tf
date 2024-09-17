# -----------------------------------------------------------------------------
# Configure AWS VPC with a single subnet, internet gateway, route table, and
# security group. Create an EC2 instance in the subnet with a public IP address
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Setup the network infrastructure: VPC, subnet, internet gateway, route table
# -----------------------------------------------------------------------------
resource "aws_vpc" "main" {
  # Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
  cidr_block           = var.base_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}_vpc"
  }
}

resource "aws_subnet" "main" {
  # Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}_main_subnet"
  }
}

resource "aws_internet_gateway" "main" {
  # Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway 
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}_main_igw"
  }
}

resource "aws_route_table" "main" {
  # Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}_main_rt"
  }
}

resource "aws_route" "default_route" {
  # Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route 
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "main" {
  # Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# -----------------------------------------------------------------------------
# Setup the security group and rules
# -----------------------------------------------------------------------------

resource "aws_security_group" "main" {
  # Reference: https://registry.terraform.io/providers/-/aws/latest/docs/resources/security_group
  name        = "${var.project_name}_main_sg"
  description = "allow all outbound traffic and ssh and http in from everywhere"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}_main_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "main" {
  # Reference: https://registry.terraform.io/providers/-/aws/latest/docs/resources/vpc_security_group_egress_rule
  # make this open to everything from everywhere
  description       = "allow all outbound traffic"
  security_group_id = aws_security_group.main.id
  ip_protocol       = "-1" # this matches all protocols
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name = "${var.project_name}_main_egress_rule"
  }

}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  # Reference: https://registry.terraform.io/providers/-/aws/latest/docs/resources/vpc_security_group_ingress_rule 
  description       = "allow ssh from everywhere"
  security_group_id = aws_security_group.main.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name = "${var.project_name}_ssh_ingress_rule"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  # Reference: https://registry.terraform.io/providers/-/aws/latest/docs/resources/vpc_security_group_ingress_rule 
  description       = "allow http from everywhere"
  security_group_id = aws_security_group.main.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name = "${var.project_name}_http_ingress_rule"
  }
}

# -----------------------------------------------------------------------------
# Setup ssh keys 
# -----------------------------------------------------------------------------

resource "tls_private_key" "main" {
  # Reference: https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
  algorithm = "ED25519"
}

resource "aws_key_pair" "main" {
  # Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
  key_name   = "${var.project_name}_key"
  public_key = tls_private_key.main.public_key_openssh

  # Generate key-pair files in current directory when creating the key pair
  # For use when SSHing to the EC2 instances
  provisioner "local-exec" {
    # Reference: https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec
    # Tutorial: https://spacelift.io/blog/terraform-provisioners
    # Using a terraform variable in shell https://stackoverflow.com/questions/71178041/how-to-insert-terraform-variable-in-shell-script
    command = <<DELIM
      echo '${tls_private_key.main.private_key_openssh}' > '${self.key_name}.pem'
      echo '${tls_private_key.main.public_key_openssh}' > '${self.key_name}.pub'
      chmod 400 ./'${self.key_name}.pem'
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
    key_name = aws_key_pair.main.key_name
  }
  # Delete the locally created key files on destroy
  provisioner "local-exec" {
    # Reference: https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec
    command = "rm -f \"${self.output.key_name}.pem\" \"${self.output.key_name}.pub\""
    when    = destroy
  }
}

# -----------------------------------------------------------------------------
# Create and run the EC2 instance 
# -----------------------------------------------------------------------------
resource "aws_instance" "main" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
  instance_type = "t2.micro"
  ami           = var.ami_id

  key_name               = "${var.project_name}_key"
  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = aws_subnet.main.id

  tags = {
    Name = "${var.project_name}_main_server"
  }

}

# Generate a shell script to set variables for the aws resources to # be used in the  in AWS CLI Operations
resource "local_file" "aws_setup" {
  # https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
  content = <<-EOT
  PROJECT="${var.project_name}"
  AMI="${var.ami_id}"
  VPC="${aws_vpc.main.id}"
  SUBNET="${aws_subnet.main.id}"
  SECURITY_GROUP="${aws_security_group.main.id}"
  GATEWAY="${aws_internet_gateway.main.id}"
  ROUTE_TABLE="${aws_route_table.main.id}"
  ROUTE_TABLE_ASSOCIATION="${aws_route_table_association.main.id}"
  SSH_KEY="${aws_key_pair.main.key_name}"
  EC2_ID="${aws_instance.main.id}"

  EOT
  filename = "${path.module}/aws_resources.sh"
}
