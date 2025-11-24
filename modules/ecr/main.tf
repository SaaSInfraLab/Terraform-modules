# =============================================================================
# ECR REPOSITORY MODULE
# =============================================================================
# Creates ECR repositories for container images with lifecycle policies
# =============================================================================

resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.kms_key_id
  }

  tags = merge(
    var.tags,
    {
      Name = var.repository_name
    }
  )
}

# Lifecycle policy to manage image retention
resource "aws_ecr_lifecycle_policy" "this" {
  count      = var.lifecycle_policy != null ? 1 : 0
  repository = aws_ecr_repository.this.name

  policy = var.lifecycle_policy
}

# Repository policy for access control
resource "aws_ecr_repository_policy" "this" {
  count      = var.repository_policy != null ? 1 : 0
  repository = aws_ecr_repository.this.name
  policy     = var.repository_policy
}

