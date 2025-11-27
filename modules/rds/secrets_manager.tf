resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "${var.name_prefix}-rds-credentials-${random_id.secret_id.hex}"
  description = "Database credentials for ${var.identifier}"
  tags        = var.tags

  # Automatically rotate the secret every 30 days
  recovery_window_in_days = 0  # Set to 0 for testing, use 7-30 in production
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username             = var.username
    password             = var.create_random_password ? random_password.master_password[0].result : var.password
    engine               = var.engine
    host                 = aws_db_instance.this.address
    port                 = var.db_port
    dbname              = var.db_name
    db_instance_identifier = aws_db_instance.this.id
  })

  depends_on = [
    aws_db_instance.this,
    random_password.master_password
  ]
}

resource "random_id" "secret_id" {
  byte_length = 8
}

# Output the secret ARN for other modules to use
output "rds_secret_arn" {
  description = "The ARN of the secret in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.rds_credentials.arn
}

# Output the secret name for reference
output "rds_secret_name" {
  description = "The name of the secret in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.rds_credentials.name
}
