output "public_dns" {
  value = aws_instance.do1-web.public_dns
}

output "public_ip" {
  value = aws_instance.do1-web.public_ip
}
