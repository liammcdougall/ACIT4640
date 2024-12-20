resource "aws_vpc" "t01_vpc" {
    cidr_block = var.subnet_cidr_block
    enable_dns_hostnames = true
    tags = {
      Name = "${var.project_name}_vpc"
    }
}

resource "aws_internet_gateway" "t01_igw" {
    vpc_id = aws_vpc.t01_vpc.id
    tags = {
    Name = "${var.project_name}_igw"
  }
}

resource "aws_route_table" "t01_rt" {
  vpc_id = aws_vpc.t01_vpc.id
  tags = {
    Name = "${var.project_name}_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.t01_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.t01_igw.id
}

resource "aws_subnet" "t01" {
    vpc_id = aws_vpc.t01_vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.availability_zone
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.project_name}_sn"
  }
}

resource "aws_route_table_association" "front" {
  subnet_id      = aws_subnet.t01.id
  route_table_id = aws_route_table.t01_rt.id
}

resource "aws_route_table_association" "back" {
  subnet_id      = aws_subnet.t01.id
  route_table_id = aws_route_table.t01_rt.id
}


resource "aws_security_group" "t01_front" {
    name = "t01_front"
    description = "PUBLIC/FRONTEND"
    vpc_id = aws_vpc.t01_vpc.id
    tags = {
        Name = "${var.project_name}_front_sg" 
    }
}

resource "aws_security_group" "t01_back" {
    name = "t01_back"
    description = "PRIVATE/BACKEND"
    vpc_id = aws_vpc.t01_vpc.id
    tags = {
        Name = "${var.project_name}_front_sg" 
    }
}
#front sec rules
resource "aws_vpc_security_group_ingress_rule" "ssh-front" {
    security_group_id = aws_security_group.t01_front.id
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = 22
    ip_protocol = "tcp"
    to_port     = 22
}
resource "aws_vpc_security_group_ingress_rule" "http-front" {
  security_group_id = aws_security_group.t01_front.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}
resource "aws_vpc_security_group_ingress_rule" "https-front" {
  security_group_id = aws_security_group.t01_front.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}
resource "aws_vpc_security_group_ingress_rule" "vpc-front-ingress" {
  security_group_id = aws_security_group.t01_front.id
  cidr_ipv4   = var.subnet_cidr_block
  ip_protocol = -1
}
resource "aws_vpc_security_group_egress_rule" "all-front-egress" {
  security_group_id = aws_security_group.t01_front.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}
resource "aws_vpc_security_group_egress_rule" "all-front-vpc-egress" {
  security_group_id = aws_security_group.t01_front.id
  cidr_ipv4   = var.subnet_cidr_block
  ip_protocol = -1
}

#back sec rules
resource "aws_vpc_security_group_ingress_rule" "ssh-back" {
    security_group_id = aws_security_group.t01_back.id
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = 22
    ip_protocol = "tcp"
    to_port     = 22
}
resource "aws_vpc_security_group_ingress_rule" "vpc-back-ingress" {
  security_group_id = aws_security_group.t01_back.id
  cidr_ipv4   = var.subnet_cidr_block
  ip_protocol = -1
}
resource "aws_vpc_security_group_egress_rule" "all-back-egress" {
  security_group_id = aws_security_group.t01_back.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}
resource "aws_vpc_security_group_egress_rule" "all-back-vpc-egress" {
  security_group_id = aws_security_group.t01_back.id
  cidr_ipv4   = var.subnet_cidr_block
  ip_protocol = -1
}

# instances

resource "aws_instance" "t01_frontend" {
    ami = var.ami_id
    instance_type = "t2.micro"
    security_groups = [aws_security_group.t01_front.id]
    subnet_id = aws_subnet.t01.id
    key_name = aws_key_pair.main.key_name
    tags = {
      Name = "t01_frontend",
      Server_Role = "frontend",
      Project = var.project_name
    }
}
resource "aws_instance" "t01_backend" {
    ami = var.ami_id
    instance_type = "t2.micro"
    security_groups = [aws_security_group.t01_back.id]
    subnet_id = aws_subnet.t01.id
    key_name = aws_key_pair.main.key_name
    tags = {
      Name = "t01_backend",
      Server_Role = "backend",
      Project = var.project_name
    }
}
resource "aws_instance" "t01_database" {
    ami = var.ami_id
    instance_type = "t2.micro"
    security_groups = [aws_security_group.t01_back.id]
    subnet_id = aws_subnet.t01.id
    key_name = aws_key_pair.main.key_name
    tags = {
      Name = "t01_database",
      Server_Role = "database",
      Project = var.project_name
    }
}

# # making ssh key
# resource "tls_private_key" "main" {
#   algorithm = "ED25519"
#   provisioner "local-exec" {
#     command = <<DELIM
#       echo '${tls_private_key.main.private_key_openssh}' > '${var.key_name}.pem'
#       echo '${tls_private_key.main.public_key_openssh}' > '${var.key_name}.pub'
#       chmod 400 ./'${var.key_name}.pem'
#     DELIM

#     when = create
#   }
# }
# resource "terraform_data" "delete_key_pair" {
#   # Reference: https://developer.hashicorp.com/terraform/language/resources/terraform-data
#   # Input stores value that is accessed in the provisioner block as output
#   input = {
#     key_name = var.key_name
#   }
#   provisioner "local-exec" {
#     # Reference: https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec
#     command = "rm -f \"${self.output.key_name}.pem\" \"${self.output.key_name}.pub\""
#     when    = destroy
#   }
# }

# # Sync SSH public key with AWS
# resource "aws_key_pair" "t01" {
#   # Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
#   key_name   = "${var.project_name}_key"
#   public_key = tls_private_key.main.public_key_openssh
# }
resource "tls_private_key" "main" {
  algorithm = "ED25519"
  provisioner "local-exec" {

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
  key_name   = "${var.project_name}"
  public_key = tls_private_key.main.public_key_openssh
}


