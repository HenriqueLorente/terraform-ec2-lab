output "public_ip" { value = aws_instance.web.public_ip }
output "public_dns" { value = aws_instance.web.public_dns }

output "http_url" {
  value       = "http://${aws_instance.web.public_ip}"
  description = "Página do Nginx (user_data)"
}
