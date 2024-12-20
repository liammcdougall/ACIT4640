variable "project_name" {
    type=string
    default = "acit4640t02_q02"
}
variable "sec_group_public" {
    type = string
    default = "public"
}

variable "sec_group_backend" {
    type = string
    default = "backend"
}
variable "availability_zone" {
  type        = string
  default     = "us-west-2a"
}
variable "aws_region" {
  type        = string
  default     = "us-west-2"
}
variable "instance_type_micro" {
    type = string
    default = "t2.micro"
  
}
variable "vpc_cidr_block" {
  type = string
  default = "value"
}
variable "public_cidr_block" {
  type = string
  default = "value"
}
variable "backend_cidr_block" {
  type = string
  default = "value"
}
variable "ubuntu_2410_ami_id" {
    type = string
    default = "value"
}
variable "b1_ip_address" {
    type = string
    default = "value"
}