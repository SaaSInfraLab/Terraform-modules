# =============================================================================
# TERRAFORM AND PROVIDER CONFIGURATION
# =============================================================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

# =============================================================================
# AWS PROVIDER
# =============================================================================

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "SaaSInfraLab"
      ManagedBy   = "Terraform"
      Phase       = "Tenants"
    }
  }
}

# =============================================================================
# KUBERNETES PROVIDER
# =============================================================================

# Get infrastructure state from Phase 1
# We use this primarily for cluster name (which is stable)
data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  
  config = {
    bucket = "saas-infra-lab-terraform-state"
    key    = "saas-infra-lab/${var.environment}/infrastructure/terraform.tfstate"
    region = "us-east-1"
  }
}

# List all EKS clusters to find the correct one
# This provides resilience if remote state has stale cluster name
data "aws_eks_clusters" "all" {}

locals {
  # Get cluster name from remote state (may be stale)
  remote_state_cluster_name = try(data.terraform_remote_state.infrastructure.outputs.cluster_name, "")
  
  # Convert set to list for indexing
  all_cluster_names = tolist(data.aws_eks_clusters.all.names)
  
  # Find the actual cluster name
  # If remote state cluster exists in AWS, use it; otherwise use the first cluster found
  # This handles cases where remote state has stale/incorrect cluster name
  actual_cluster_name = length(local.all_cluster_names) > 0 && contains(local.all_cluster_names, local.remote_state_cluster_name) ? local.remote_state_cluster_name : (
    length(local.all_cluster_names) > 0 ? local.all_cluster_names[0] : local.remote_state_cluster_name
  )
}

# Get current cluster info directly from AWS (always up-to-date)
# This ensures we always get the current endpoint, even if remote state is stale
# Uses fallback logic to handle stale cluster names in remote state
data "aws_eks_cluster" "current" {
  name = local.actual_cluster_name
}

provider "kubernetes" {
  # Use endpoint from AWS data source (always current) instead of remote state
  # This prevents errors when remote state has stale endpoint data
  host                   = data.aws_eks_cluster.current.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.current.certificate_authority[0].data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.current.name, "--region", var.aws_region]
  }
}