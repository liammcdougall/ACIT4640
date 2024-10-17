project_name  = "wk07_demo"
ubuntu_ami_id = "ami-0819177b8e6d4947a"
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
  chat_8023 = {
    name        = "chat_8023"
    description = "Allows SSH, 8023, and intra-vpc ingress access and all egress"
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
        description          = "8023 access from home"
        ip_protocol          = "tcp"
        from_port            = 8023
        to_port              = 8023
        ipv4_cidr_block_name = "home"
        rule_name            = "home_access_8023"
      },
      {
        description          = "8023 access from BCIT"
        ip_protocol          = "tcp"
        from_port            = 8023
        to_port              = 8023
        ipv4_cidr_block_name = "bcit"
        rule_name            = "bcit_access_8023"
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
  chat_8024 = {
    name        = "chat_8024"
    description = "Allows SSH, 8024, and intra-vpc ingress access and all egress"
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
        description          = "8024 access from home"
        ip_protocol          = "tcp"
        from_port            = 8024
        to_port              = 8024
        ipv4_cidr_block_name = "home"
        rule_name            = "home_access_8024"
      },
      {
        description          = "8024 access from BCIT"
        ip_protocol          = "tcp"
        from_port            = 8024
        to_port              = 8024
        ipv4_cidr_block_name = "bcit"
        rule_name            = "bcit_access_8024"
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
    name           = "c_01"
    subnet         = "main"
    role           = "role_one"
    security_group = "chat_8023"
    type           = "t2.micro"
    ami_id         = "ami-093881f5d02adcb35"
    distro         = "centos"
  },
  {
    name           = "u_01"
    subnet         = "main"
    role           = "role_two"
    security_group = "chat_8024"
    type           = "t2.micro"
    ami_id         = "ami-0819177b8e6d4947a"
    distro         = "ubuntu"
  }
]
