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
data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  
  config = {
    bucket = "saas-infra-lab-terraform-state"
    key    = "saas-infra-lab/infrastructure/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.infrastructure.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infrastructure.outputs.cluster_certificate_authority_data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.infrastructure.outputs.cluster_name, "--region", var.aws_region]
  }
}