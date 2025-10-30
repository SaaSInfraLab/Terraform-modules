# =============================================================================
# SAAS INFRALAB - TENANTS PHASE
# =============================================================================
# This configuration deploys multi-tenant Kubernetes resources:
# - Tenant namespaces with isolation
# - RBAC for namespace-level access control
# - Resource quotas for CPU, memory, storage limits
# - Network policies for traffic isolation
# - IAM roles for service accounts (IRSA)
# =============================================================================

locals {
  cluster_name = data.terraform_remote_state.infrastructure.outputs.cluster_name
  
  common_tags = {
    Environment = var.environment
    Project     = "SaaSInfraLab"
    ManagedBy   = "Terraform"
    Phase       = "Tenants"
    ClusterName = local.cluster_name
    Repository  = "cloudnative-saas-eks"
  }
}

# =============================================================================
# MULTI-TENANCY MODULE
# =============================================================================

module "multi_tenancy" {
  source = "../modules/multi-tenancy"
  
  # Tenant configurations
  tenants = var.tenants
  
  # Cluster information from infrastructure phase
  cluster_name = local.cluster_name
  aws_region   = var.aws_region
  
  # Multi-tenancy features
  enable_rbac                = true
  enable_namespace_isolation = true
  
  # Tags
  tags = local.common_tags
}