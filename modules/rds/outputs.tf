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

output "db_instance_address" {
  description = "The address (hostname only) for the RDS instance"
  value       = aws_db_instance.main.address
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

# Password is managed by AWS Secrets Manager - use the secret ARN to retrieve it

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

output "rds_secret_arn" {
  description = "The ARN of the secret in AWS Secrets Manager (automatically managed by RDS)"
  value       = try(aws_db_instance.main.master_user_secret[0].secret_arn, null)
}

output "rds_secret_name" {
  description = "The name of the secret in AWS Secrets Manager (automatically managed by RDS). AWS uses pattern: rds-db-credentials/<identifier>"
  value       = "rds-db-credentials/${var.identifier}"
}

output "db_connection_info" {
  description = "Database connection information (retrieve password from Secrets Manager using secret_arn)"
  value = {
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
    database = aws_db_instance.main.db_name
    username = aws_db_instance.main.username
    secret_arn = try(aws_db_instance.main.master_user_secret[0].secret_arn, null)
  }
}
