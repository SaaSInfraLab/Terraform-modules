resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Security group for RDS ${var.engine} instance"
  vpc_id      = var.vpc_id
  
  dynamic "ingress" {
    for_each = var.allowed_security_group_ids != null ? [1] : []
    content {
      from_port       = var.db_port
      to_port         = var.db_port
      protocol        = "tcp"
      security_groups = var.allowed_security_group_ids
      description     = "Allow database access from allowed security groups"
    }
  }

  dynamic "ingress" {
    for_each = var.allowed_cidr_blocks != null ? [1] : []
    content {
      from_port   = var.db_port
      to_port     = var.db_port
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
      description = "Allow database access from CIDR blocks"
    }
  }

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

resource "random_password" "master_password" {
  count = var.create_random_password ? 1 : 0
  
  length           = 16
  special          = true
  override_special = "_%"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
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
  password = var.create_random_password ? random_password.master_password[0].result : var.password
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
  
  multi_az               = var.multi_az
  apply_immediately      = var.apply_immediately
  deletion_protection    = var.deletion_protection
  
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

resource "aws_ssm_parameter" "db_password" {
  count = var.store_password_in_ssm ? 1 : 0
  
  name        = "/${var.name_prefix}/db/password"
  description = "Database password for ${var.identifier}"
  type        = "SecureString"
  value       = aws_db_instance.main.password
  
  tags = var.tags
  
  lifecycle {
    ignore_changes = [value]
  }
}
