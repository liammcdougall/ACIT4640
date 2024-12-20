# -----------------------------------------------------------------------------
# Setup the network infrastructure: VPC, subnet, internet gateway, route table
# -----------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}"
  }
}
resource "aws_internet_gateway" "main" {
  vpc_id =   aws_vpc.main.id
  tags = {
    Name = "${var.project_name}"
  }
}
resource "aws_route_table" "lab03_rt" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}_rt"
  }
}

resource "aws_subnet" "sn_public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}_sn_public"
  }
}

resource "aws_subnet" "sn_backend" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.backend_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}_sn_backend"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}_rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.sn_public.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "backend" {
  subnet_id      = aws_subnet.sn_backend.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "public" {
  name        = "public"
  description = "Public subnet accessible via web and ssh"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}_public"
  }
}
resource "aws_security_group" "backend" {
  name        = "backend"
  description = "Private subnet accessible via ssh"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}_backend"
  }
}
resource "aws_vpc_security_group_ingress_rule" "public-ssh" {
  security_group_id = aws_security_group.public.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "public-http" {
  security_group_id = aws_security_group.public.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "public-all-egress" {
  security_group_id = aws_security_group.public.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_vpc_security_group_egress_rule" "public-vpc-egress" {
  security_group_id = aws_security_group.public.id
  cidr_ipv4   = var.vpc_cidr_block
  ip_protocol = -1
}


resource "aws_vpc_security_group_ingress_rule" "backend-ssh" {
  security_group_id = aws_security_group.backend.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}
resource "aws_vpc_security_group_egress_rule" "backend-all-egress" {
  security_group_id = aws_security_group.backend.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}
resource "aws_vpc_security_group_egress_rule" "backend-vpc-egress" {
  security_group_id = aws_security_group.backend.id
  cidr_ipv4   = var.vpc_cidr_block
  ip_protocol = -1
}
resource "aws_vpc_security_group_ingress_rule" "backend-vpc-ingress" {
  security_group_id = aws_security_group.backend.id

  cidr_ipv4   = var.vpc_cidr_block
  ip_protocol = -1
}
# -----------------------------------------------------------------------------
# Setup ssh key 
# -----------------------------------------------------------------------------
resource "tls_private_key" "main" {
  algorithm = "ED25519"

  # Generate key-pair files in current directory when creating the key pair
  # For use when SSHing to the EC2 instances
  provisioner "local-exec" {
    command = <<DELIM
      echo '${tls_private_key.main.private_key_openssh}' > '${var.project_name}.pem'
      echo '${tls_private_key.main.public_key_openssh}' > '${var.project_name}.pub'
      chmod 400 ./'${var.project_name}.pem'
    DELIM

    when = create
  }
}

# Create a data source  that will be used to delete the key pair files when the
# infrastructure is destroyed. This avoids polluting the local filesystem with
# key files
resource "terraform_data" "delete_key_pair" {
  input = {
    key_name = var.project_name
  }
  provisioner "local-exec" {
    command = "rm -f \"${self.output.key_name}.pem\" \"${self.output.key_name}.pub\""
    when    = destroy
  }
}

# Sync SSH public key with AWS
resource "aws_key_pair" "main" {
  key_name   = var.project_name
  public_key = tls_private_key.main.public_key_openssh
}





# EC2 instances creation
resource "aws_instance" "w1" {
  ami = var.ubuntu_2410_ami_id
  instance_type = var.instance_type_micro
  key_name = var.project_name
  security_groups = [aws_security_group.public.id]
  subnet_id = aws_subnet.sn_public.id
  tags = {
    Name = "w1"
    Server_Role = "web"
  }
}

resource "aws_instance" "w2" {
  ami = var.ubuntu_2410_ami_id
  instance_type = var.instance_type_micro
  key_name = var.project_name
  security_groups = [aws_security_group.public.id]
  subnet_id = aws_subnet.sn_public.id
  tags = {
    Name = "w2"
    Server_Role = "web"
  }
}

resource "aws_instance" "b1" {
  ami = var.ubuntu_2410_ami_id
  instance_type = var.instance_type_micro
  security_groups = [aws_security_group.backend.id]
  subnet_id = aws_subnet.sn_backend.id
  key_name = var.project_name
  private_ip = var.b1_ip_address
  tags = {
    Name = "b1"
    Server_Role = "be"
  }
}

