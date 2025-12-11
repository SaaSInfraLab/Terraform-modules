# No locals needed - variables have default empty lists

resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Security group for RDS ${var.engine} instance"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.tags,
    { Name = "${var.name_prefix}-rds-sg" }
  )
}

# Security group rules for allowed security groups
# Note: If you get "duplicate rule" errors, the rules already exist in AWS.
# Import them with: terraform import 'module.rds.aws_security_group_rule.rds_ingress_from_sg["<sg-id>"]' <rule-id>
resource "aws_security_group_rule" "rds_ingress_from_sg" {
  for_each = toset(var.allowed_security_group_ids)
  
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.rds.id
  description              = "Allow database access from allowed security groups"
}

# Security group rules for allowed CIDR blocks
resource "aws_security_group_rule" "rds_ingress_from_cidr" {
  for_each = toset(var.allowed_cidr_blocks)
  
  type              = "ingress"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.rds.id
  description       = "Allow database access from CIDR blocks"
}

resource "aws_db_instance" "main" {
  identifier     = var.identifier
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  
  db_name  = var.db_name
  username = var.username
  # Use AWS Secrets Manager to manage the password automatically
  # This eliminates the need for password conditionals and prevents Terraform crashes
  manage_master_user_password = true
  port     = var.db_port
  
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = var.publicly_accessible
  
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  skip_final_snapshot    = var.skip_final_snapshot
  
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_role_arn
  
  multi_az                    = var.multi_az
  apply_immediately           = var.apply_immediately
  deletion_protection         = var.deletion_protection
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  
  parameter_group_name = var.parameter_group_name != null ? var.parameter_group_name : (
    var.engine == "postgres" ? aws_db_parameter_group.default[0].name : null
  )
  
  tags = merge(
    var.tags,
    { Name = var.identifier }
  )
  
  depends_on = [
    aws_db_parameter_group.default
  ]
}

resource "aws_db_parameter_group" "default" {
  count = var.engine == "postgres" ? 1 : 0
  
  name_prefix = "${var.name_prefix}-"
  family      = "${var.engine}${var.engine_version_major}"
  
  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = var.tags
}

# Password is now managed by AWS Secrets Manager automatically
# No need for SSM parameter - use the managed secret instead
