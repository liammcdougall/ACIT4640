output "web_dns" {
  value = aws_instance.lab03_web_w1.public_dns
}

output "backend_dns" {
  value = aws_instance.lab03_backend_b1.public_dns
}
