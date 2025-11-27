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
    host                 = aws_db_instance.main.address
    port                 = var.db_port
    dbname              = var.db_name
    db_instance_identifier = aws_db_instance.main.id
  })

  depends_on = [
    aws_db_instance.main,
    random_password.master_password
  ]
}

resource "random_id" "secret_id" {
  byte_length = 8
}
