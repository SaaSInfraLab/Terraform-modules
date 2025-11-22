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
    key    = "saas-infra-lab/infrastructure/terraform.tfstate"
    region = "us-east-1"
  }
}

# Get current cluster info directly from AWS (always up-to-date)
# This ensures we always get the current endpoint, even if remote state is stale
# This is the long-term solution to prevent stale endpoint errors
data "aws_eks_cluster" "current" {
  name = data.terraform_remote_state.infrastructure.outputs.cluster_name
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