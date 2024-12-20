output "backend_dns_name" {
    value = aws_instance.t01_backend.public_dns
}
output "database_dns_name" {
    value = aws_instance.t01_database.public_dns
}
output "frontend_dns_name" {
    value = aws_instance.t01_frontend.public_dns
}

output "aws_key_private_key_file" {
  value = "${aws_key_pair.main.key_name}.pem"
}
