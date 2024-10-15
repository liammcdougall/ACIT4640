project_name = "wk07_lab"
ubuntu_ami_id       = "ami-0819177b8e6d4947a" # Ubuntu 2024.04 LTS x86-64 Image
centos_ami_id = "ami-093881f5d02adcb35"

cidr_blocks = {
  "vpc_cidr" = {
    address     = "172.16.0.0"
    cidr_bits   = 16
    description = "VPC CIDR"
    subnet      = false
  },
  "home" = {
    address     = "174.7.180.0"
    cidr_bits   = 24
    description = "Home network"
    subnet      = false
  },
  "bcit" = {
    address     = "142.232.0.0"
    cidr_bits   = 16
    description = "BCIT Network"
    subnet      = false
  },
  "default" = {
    address     = "0.0.0.0"
    cidr_bits   = 0
    description = "default"
    subnet      = false
  },
  "main" = {
    address     = "172.16.254.0"
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

instance_configs = [
  {
    name           = "fe_01"
    subnet         = "main"
    role           = "fe"
    security_group = "public"
    type           = "t2.micro"
  },
  {
    name           = "fe_02"
    subnet         = "main"
    role           = "fe"
    security_group = "public"
    type           = "t2.micro"
  },
  {
    name           = "fe_03"
    subnet         = "main"
    role           = "fe"
    security_group = "public"
    type           = "t2.micro"
  },
  {
    name           = "be_01"
    subnet         = "main"
    role           = "be"
    security_group = "public"
    type           = "t2.micro"
  }
]
