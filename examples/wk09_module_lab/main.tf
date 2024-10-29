module "vpc" {
  source       = "./modules/terraform_vpc_simple"
  project_name = var.project_name
  vpc_cidr     = "172.16.1.0/24"
  subnet_cidr  = "172.16.1.0/25"
  home_net     = "75.157.34.0/24"
  aws_region   = "us-west-2"
}

module "ec2" {
  source = "./modules/terraform_ec2_simple"
  project_name = var.project_name
  aws_region = var.aws_region
  ami_id = var.ami_id
  subnet_id = module.vpc.sn_1_id
  security_group_id = module.vpc.sg_1_id
  ssh_key_name = var.ssh_key_name
}
