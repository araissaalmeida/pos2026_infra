output "app_public_ip" {
  description = "Public IP address of the EC2 instance that hosts the API and frontend."
  value       = aws_instance.web.public_ip
}

output "app_public_dns" {
  description = "Public DNS name of the EC2 instance that hosts the API and frontend."
  value       = aws_instance.web.public_dns
}

output "db_endpoint" {
  description = "RDS endpoint without the port, used by the backend."
  value       = aws_db_instance.myapp_db.address
}

output "db_name" {
  description = "Initial database name created by RDS."
  value       = aws_db_instance.myapp_db.db_name
}

output "db_username" {
  description = "Database user configured in Terraform."
  value       = aws_db_instance.myapp_db.username
}
