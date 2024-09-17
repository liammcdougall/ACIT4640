output "vpc_id" {
  value = aws_vpc.main.id
}

output "ec2_dns" {
  value = aws_instance.main.public_dns
}

output "ec2_ip" {
  value = aws_instance.main.public_ip
}

output "aws_key_pair_name" {
  value = aws_key_pair.main.key_name
}

output "aws_key_private_key_file" {
  value = "${aws_key_pair.main.key_name}.pem"
}