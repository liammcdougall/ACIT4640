output "vpc" {
  value = aws_vpc.main.tags_all
}
output "public_security_group_ingress_rules" {
  value = aws_security_group.public.ingress
}
output "backend_security_group_ingress_rules" {
  value = aws_security_group.backend.ingress
}
output "w1_name" {
  value = aws_instance.w1.public_dns
}
output "w2_name" {
  value = aws_instance.w2.public_dns
}
output "b1_name" {
  value = aws_instance.b1.public_dns
}

output "b1_ip" {
  value = aws_instance.b1.private_ip
}

output "aws_key_pair" {
  value = aws_key_pair.main.key_name
}
