locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Repository  = "terraform-modules"
    }
  )
}

# ============================================================================
# IAM Module - Centralized role management
# ============================================================================
module "iam" {
  source = "../../iam"

  create_eks_cluster_role       = true
  create_eks_node_role          = true
  create_vpc_flow_logs_role     = true
  create_cloudwatch_agent_role  = true

  name_prefix  = var.name_prefix
  cluster_name = var.cluster_name
  
  tags = local.common_tags
}

# ============================================================================
# VPC Module - Networking foundation
# ============================================================================
module "vpc" {
  source = "../../vpc"

  name_prefix    = var.name_prefix
  vpc_cidr       = var.vpc_cidr
  azs            = var.availability_zones
  enable_flow_logs = true
  vpc_flow_logs_role_arn = module.iam.vpc_flow_logs_role_arn

  tags = local.common_tags

  depends_on = [module.iam]
}

# ============================================================================
# EKS Module - Kubernetes control plane and nodes
# ============================================================================
module "eks" {
  source = "../../eks"

  cluster_name                = var.cluster_name
  cluster_version             = var.cluster_version
  create_cluster_log_group    = true
  
  cluster_iam_role_arn        = module.iam.eks_cluster_role_arn
  node_iam_role_arn           = module.iam.eks_node_role_arn

  vpc_id                      = module.vpc.vpc_id
  private_subnet_ids          = module.vpc.private_subnet_ids
  public_subnet_ids           = module.vpc.public_subnet_ids
  cluster_security_group_id   = module.vpc.eks_cluster_sg_id
  nodes_security_group_id     = module.vpc.eks_nodes_sg_id

  node_group_desired_size     = var.node_desired_size
  node_group_min_size         = var.node_min_size
  node_group_max_size         = var.node_max_size
  node_instance_types         = var.node_instance_types

  tags = local.common_tags

  depends_on = [
    module.iam,
    module.vpc
  ]
}

# ============================================================================
# Monitoring Module - CloudWatch and observability
# ============================================================================
module "monitoring" {
  source = "../../monitoring"

  cluster_name                   = module.eks.cluster_name
  enable_container_insights      = var.enable_container_insights
  log_group_retention_days       = var.log_retention_days
  enable_alarms                  = var.enable_security_alarms
  cloudwatch_agent_role_arn      = module.iam.cloudwatch_agent_role_arn

  tags = local.common_tags

  depends_on = [module.eks]
}

# ============================================================================
# Security Module - Security groups, NACLs, network policies
# ============================================================================
module "security" {
  source = "../../security"

  vpc_id                      = module.vpc.vpc_id
  cluster_security_group_id   = module.vpc.eks_cluster_sg_id
  nodes_security_group_id     = module.vpc.eks_nodes_sg_id
  cluster_name                = var.cluster_name
  allowed_cidr_blocks         = var.allowed_cidr_blocks
  enable_network_policy       = var.enable_network_policies

  tags = local.common_tags

  depends_on = [
    module.vpc,
    module.eks
  ]
}

#============================================================================
# Multi-Tenancy Module - Namespace isolation and RBAC (Temporarily disabled)
#============================================================================
module "multi_tenancy" {
  source = "../../multi-tenancy"

  count = length(var.tenants) > 0 ? 1 : 0

  cluster_name                = module.eks.cluster_name
  enable_rbac                 = true
  enable_namespace_isolation  = true
  enable_service_accounts     = true
  
  tenants = var.tenants

  tags = local.common_tags

  depends_on = [
    module.eks,
    module.monitoring
  ]
}
