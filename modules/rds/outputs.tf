output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_port" {
  description = "The port the database is listening on"
  value       = aws_db_instance.main.port
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = aws_db_instance.main.password
  sensitive   = true
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.main.db_name
}

output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = aws_db_subnet_group.main.id
}

output "db_subnet_group_arn" {
  description = "The ARN of the db subnet group"
  value       = aws_db_subnet_group.main.arn
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.rds.id
}

output "ssm_parameter_name" {
  description = "The name of the SSM parameter storing the database password (if store_password_in_ssm is true)"
  value       = var.store_password_in_ssm ? aws_ssm_parameter.db_password[0].name : null
}

output "ssm_parameter_arn" {
  description = "The ARN of the SSM parameter storing the database password (if store_password_in_ssm is true)"
  value       = var.store_password_in_ssm ? aws_ssm_parameter.db_password[0].arn : null
}
