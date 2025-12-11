####################
# IAM: Secrets Manager Role for IRSA
####################
resource "aws_iam_role" "secrets_manager" {
  count = var.create_secrets_manager_role && var.oidc_provider_arn != "" && var.oidc_provider_url != "" ? 1 : 0
  name  = "${local.prefix}-secrets-manager-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:${var.secrets_manager_namespace}:${var.secrets_manager_service_account}"
            "${replace(var.oidc_provider_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "secrets_manager_policy" {
  count = var.create_secrets_manager_role && var.oidc_provider_arn != "" && var.oidc_provider_url != "" ? 1 : 0
  name  = "${local.prefix}-secrets-manager-policy"
  role  = aws_iam_role.secrets_manager[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      # Allow access to secrets
      [
        {
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Resource = length(var.secrets_manager_secret_arns) > 0 ? var.secrets_manager_secret_arns : ["*"]
        }
      ],
      # KMS decryption
      [
        {
          Effect = "Allow"
          Action = [
            "kms:Decrypt"
          ]
          Resource = length(var.secrets_manager_kms_key_arns) > 0 ? var.secrets_manager_kms_key_arns : ["*"]
          Condition = {
            StringEquals = {
              "kms:ViaService" = "secretsmanager.${data.aws_region.current.name}.amazonaws.com"
            }
          }
        }
      ]
    )
  })
}

data "aws_region" "current" {}

