project_name = "wk06_lab"
ami_id       = "ami-0819177b8e6d4947a" # Ubuntu 2024.04 LTS x86-64 Image

cidr_blocks = {
  "vpc_cidr" = {
    address = "172.16.0.0"
    cidr_bits   = 16
    description = "VPC CIDR"
    subnet      = false
  },
  "home" = {
    address = "75.157.0.0"
    cidr_bits   = 16
    description = "Home network"
    subnet      = false
  },
  "bcit" = {
    address = "142.232.0.0"
    cidr_bits   = 16
    description = "BCIT Network"
    subnet      = false
  },
  "default" = {
    address = "0.0.0.0"
    cidr_bits   = 0
    description = "default"
    subnet      = false
  },
  "main" = {
    address = "172.16.254.0"
    cidr_bits   = 24
    description = "Public subnet"
    subnet      = true
    az          = "us-west-2a"
  },
}

security_groups = {
  public = {
    name        = "public"
    description = "Allows ssh, web, and intra-vpc ingress access and all egress"
    ingress_rules = [
      {
        description          = "web access from home"
        ip_protocol          = "tcp"
        from_port            = 80
        to_port              = 80
        ipv4_cidr_block_name = "default" #FROM ANYWHERE
        rule_name            = "web_access_anywhere"
      },
      {
        description          = "ssh access from home"
        ip_protocol          = "tcp"
        from_port            = 22
        to_port              = 22
        ipv4_cidr_block_name = "default" #FROM ANYWHERE
        rule_name            = "ssh_access_anywhere"
      },
      {
        description          = "ssh access from home"
        ip_protocol          = "tcp"
        from_port            = 22
        to_port              = 22
        ipv4_cidr_block_name = "home"
        rule_name            = "ssh_access_home"
      },
      {
        description          = "ssh access from bcit"
        ip_protocol          = "tcp"
        from_port            = 22
        to_port              = 22
        ipv4_cidr_block_name = "bcit"
        rule_name            = "ssh_access_bcit"
      },
      {
        description          = "web access from home"
        ip_protocol          = "tcp"
        from_port            = 80
        to_port              = 80
        ipv4_cidr_block_name = "home"
        rule_name            = "web_access_home"
      },
      {
        description          = "web access from bcit"
        ip_protocol          = "tcp"
        from_port            = 80
        to_port              = 80
        ipv4_cidr_block_name = "bcit"
        rule_name            = "web_access_bcit"
      },
      {
        description          = "internal access within the vpc"
        ip_protocol          = "-1"
        from_port            = null
        to_port              = null
        ipv4_cidr_block_name = "vpc_cidr"
        rule_name            = "intra_vpc_access"
      }
    ]
    egress_rules = [
      {
        description          = "allow all egress traffic"
        ip_protocol          = "-1"
        from_port            = null
        to_port              = null
        ipv4_cidr_block_name = "default"
        rule_name            = "allow_all_egress"
      }
    ]
  },
}

instance_configs = {
  w1 = {
    subnet         = "main"
    role           = "web"
    security_group = "public"
    type           = "t2.micro"
  },
  w2 = {
    subnet         = "main"
    role           = "web"
    security_group = "public"
    type           = "t2.micro"
  }
  w3 = {
    subnet         = "main"
    role           = "web"
    security_group = "public"
    type           = "t2.micro"
  }
  b1 = {
    subnet         = "main"
    role           = "backend"
    security_group = "public"
    type           = "t2.micro"
  }
}