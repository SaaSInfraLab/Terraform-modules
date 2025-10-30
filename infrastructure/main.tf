# =============================================================================
# SAAS INFRALAB - INFRASTRUCTURE PHASE
# =============================================================================
# This configuration deploys core AWS infrastructure:
# - VPC with public/private subnets across 3 AZs
# - EKS cluster with managed node groups
# - IAM roles and policies
# - Security groups and network ACLs
# - CloudWatch monitoring and logging
# =============================================================================

locals {
  common_tags = {
    Environment = var.environment
    Project     = "SaaSInfraLab"
    ManagedBy   = "Terraform"
    Phase       = "Infrastructure"
    Repository  = "cloudnative-saas-eks"
  }
}

# =============================================================================
# IAM ROLES & POLICIES
# =============================================================================

module "iam" {
  source = "../modules/iam"
  
  create_eks_cluster_role      = true
  create_eks_node_role         = true
  create_vpc_flow_logs_role    = true
  create_cloudwatch_agent_role = true
  
  name_prefix  = var.cluster_name
  cluster_name = var.cluster_name
  
  tags = local.common_tags
}

# =============================================================================
# VPC & NETWORKING
# =============================================================================

module "vpc" {
  source = "../modules/vpc"
  
  name_prefix            = "${var.cluster_name}-vpc"
  vpc_cidr               = var.vpc_cidr
  azs                    = var.availability_zones
  enable_flow_logs       = var.enable_flow_logs
  vpc_flow_logs_role_arn = module.iam.vpc_flow_logs_role_arn
  
  tags = local.common_tags
  
  depends_on = [module.iam]
}

# =============================================================================
# EKS CLUSTER
# =============================================================================

module "eks" {
  source = "../modules/eks"
  
  cluster_name                     = var.cluster_name
  cluster_version                  = var.cluster_version
  create_cluster_log_group         = true
  
  # Endpoint configuration
  cluster_endpoint_private_access  = var.cluster_endpoint_config.private_access
  cluster_endpoint_public_access   = var.cluster_endpoint_config.public_access
  
  # IAM roles
  cluster_iam_role_arn = module.iam.eks_cluster_role_arn
  node_iam_role_arn    = module.iam.eks_node_role_arn
  
  # Network configuration
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  public_subnet_ids         = module.vpc.public_subnet_ids
  cluster_security_group_id = module.vpc.eks_cluster_sg_id
  nodes_security_group_id   = module.vpc.eks_nodes_sg_id
  
  # Node group configuration
  node_group_desired_size = var.node_group_config.scaling_config.desired_size
  node_group_max_size     = var.node_group_config.scaling_config.max_size
  node_group_min_size     = var.node_group_config.scaling_config.min_size
  node_instance_types     = var.node_group_config.instance_types
  
  tags = local.common_tags
  
  depends_on = [module.iam, module.vpc]
}

# =============================================================================
# MONITORING & LOGGING
# =============================================================================

module "monitoring" {
  source = "../modules/monitoring"
  
  cluster_name                 = module.eks.cluster_name
  enable_container_insights    = var.enable_monitoring
  log_group_retention_days     = var.log_retention_days
  enable_alarms                = var.enable_monitoring
  cloudwatch_agent_role_arn    = module.iam.cloudwatch_agent_role_arn
  
  tags = local.common_tags
  
  depends_on = [module.eks]
}

# =============================================================================
# SECURITY
# =============================================================================

module "security" {
  source = "../modules/security"
  
  cluster_name              = var.cluster_name
  vpc_id                    = module.vpc.vpc_id
  cluster_security_group_id = module.vpc.eks_cluster_sg_id
  nodes_security_group_id   = module.vpc.eks_nodes_sg_id
  
  tags = local.common_tags
  
  depends_on = [module.eks]
}