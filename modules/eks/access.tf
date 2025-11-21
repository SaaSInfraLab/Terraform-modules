# =============================================================================
# EKS CLUSTER ACCESS MANAGEMENT
# =============================================================================
# This file manages EKS cluster access entries and policies.
# Best practices:
# 1. Use IAM roles instead of IAM users when possible
# 2. Grant least-privilege access (not everyone needs cluster admin)
# 3. Auto-include the Terraform executor for initial access
# 4. Use environment-specific access lists
# =============================================================================

# Get current caller identity to auto-include Terraform executor
data "aws_caller_identity" "executor" {}

# Merge provided access principals with auto-detected executor
locals {
  # Auto-include the current caller (Terraform executor) if enabled
  auto_include_executor = var.auto_include_executor ? [data.aws_caller_identity.executor.arn] : []
  
  # Combine all access principals (deduplicated)
  all_access_principals = distinct(concat(
    local.auto_include_executor,
    var.cluster_access_principals
  ))
  
  # Create a map of principal ARN -> access configuration
  # Defaults to cluster admin if not specified
  access_config = {
    for principal in local.all_access_principals :
    principal => lookup(var.cluster_access_config, principal, {
      policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      access_scope = {
        type        = "cluster"
        namespaces  = []
      }
    })
  }
}

# EKS Access Entries for IAM principals (users/roles) to access the cluster
resource "aws_eks_access_entry" "cluster_access" {
  for_each     = toset(local.all_access_principals)
  cluster_name = aws_eks_cluster.main.name
  principal_arn = each.value

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-access-${replace(replace(each.value, "/", "-"), ":", "-")}"
      Principal    = each.value
      ManagedBy    = "Terraform"
    }
  )

  depends_on = [aws_eks_cluster.main]
}

# Associate access policies with access entries
# Supports different policies per principal (cluster admin, view-only, etc.)
resource "aws_eks_access_policy_association" "cluster_access_policy" {
  for_each = local.access_config

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.key
  policy_arn    = each.value.policy_arn

  access_scope {
    type        = each.value.access_scope.type
    namespaces  = each.value.access_scope.namespaces
  }

  depends_on = [aws_eks_access_entry.cluster_access]
}

