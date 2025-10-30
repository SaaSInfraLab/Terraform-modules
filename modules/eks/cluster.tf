// EKS Cluster Control Plane
resource "aws_eks_cluster" "main" {
  name            = var.cluster_name
  role_arn        = var.cluster_iam_role_arn
  version         = var.cluster_version
  enabled_cluster_log_types = var.cluster_enabled_log_types

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  # Explicitly set access config to avoid auto mode
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  tags = merge(
    var.tags,
    { Name = var.cluster_name }
  )

  depends_on = [
    aws_cloudwatch_log_group.cluster
  ]
}

// CloudWatch Log Group for EKS cluster logs
resource "aws_cloudwatch_log_group" "cluster" {
  count             = var.create_cluster_log_group ? 1 : 0
  name              = "/aws/eks/${var.cluster_name}"
  retention_in_days = var.cluster_log_retention_days

  tags = merge(
    var.tags,
    { Name = "/aws/eks/${var.cluster_name}" }
  )
}

// OIDC Provider for IRSA (IAM Roles for Service Accounts)
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = merge(
    var.tags,
    { Name = "${var.cluster_name}-irsa" }
  )
}
