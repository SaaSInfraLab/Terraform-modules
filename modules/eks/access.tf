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
  # Explicitly reference the access config variable (ensures linter can resolve it)
  access_config_map = var.cluster_access_config

  # Create a map for executor if auto-include is enabled
  # Use a static key (known at plan time) to avoid for_each issues
  # The ARN value will be resolved at apply time
  executor_map = var.auto_include_executor ? {
    "terraform-executor" = data.aws_caller_identity.executor.arn
  } : {}

  # Create a map of explicitly provided principals (known at plan time)
  # Filter out the executor ARN if auto-include is enabled to avoid duplicates
  # Note: Comparison happens at apply time, but Terraform handles this correctly
  explicit_principals_map = {
    for principal in var.cluster_access_principals :
    principal => principal
    if !var.auto_include_executor || principal != data.aws_caller_identity.executor.arn
  }

  # Combine all access principals as a map (for_each requires map with known keys)
  # Explicit principals are known, executor ARN will be resolved at apply
  all_access_principals_map = merge(
    local.explicit_principals_map,
    local.executor_map
  )

  # Create a map of principal ARN -> access configuration
  # Defaults to cluster admin if not specified
  # Handle explicitly provided principals (known at plan time)
  # Filter out executor ARN if auto-include is enabled to avoid duplicates
  explicit_access_config = {
    for principal in var.cluster_access_principals :
    principal => lookup(local.access_config_map, principal, {
      policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      access_scope = {
        type       = "cluster"
        namespaces = []
      }
    })
    if !var.auto_include_executor || principal != data.aws_caller_identity.executor.arn
  }

  # Handle executor access config
  # Use static key to match executor_map structure
  executor_access_config = var.auto_include_executor ? {
    "terraform-executor" = lookup(
      local.access_config_map,
      data.aws_caller_identity.executor.arn,
      {
        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        access_scope = {
          type       = "cluster"
          namespaces = []
        }
      }
    )
  } : {}

  # Merge both configs
  access_config = merge(
    local.explicit_access_config,
    local.executor_access_config
  )
}

# EKS Access Entries for IAM principals (users/roles) to access the cluster
resource "aws_eks_access_entry" "cluster_access" {
  for_each      = local.all_access_principals_map
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.value

  tags = merge(
    var.tags,
    {
      Name      = "${var.cluster_name}-access-${replace(replace(each.value, "/", "-"), ":", "-")}"
      Principal = each.value
      ManagedBy = "Terraform"
    }
  )

  # Prevent errors if access entry already exists (e.g., from previous runs or manual creation)
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_eks_cluster.main]
}

# Associate access policies with access entries
# Supports different policies per principal (cluster admin, view-only, etc.)
resource "aws_eks_access_policy_association" "cluster_access_policy" {
  for_each = local.access_config

  cluster_name  = aws_eks_cluster.main.name
  # For executor, use the ARN from executor_map; for others, use the key directly
  principal_arn = each.key == "terraform-executor" ? local.executor_map["terraform-executor"] : each.key
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = each.value.access_scope.type
    namespaces = each.value.access_scope.namespaces
  }

  depends_on = [aws_eks_access_entry.cluster_access]
}

