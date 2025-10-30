# =============================================================================
# CORE CONFIGURATION
# =============================================================================

variable "aws_region" {
  description = "AWS region for infrastructure deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# =============================================================================
# EKS CLUSTER CONFIGURATION
# =============================================================================

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "saasinfralab-dev"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.31"
}

variable "cluster_endpoint_config" {
  description = "EKS cluster endpoint configuration"
  type = object({
    private_access = bool
    public_access  = bool
    public_access_cidrs = list(string)
  })
  default = {
    private_access      = true
    public_access       = true
    public_access_cidrs = ["0.0.0.0/0"]
  }
}

# =============================================================================
# VPC CONFIGURATION
# =============================================================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# =============================================================================
# NODE GROUP CONFIGURATION
# =============================================================================

variable "node_group_config" {
  description = "EKS node group configuration"
  type = object({
    instance_types = list(string)
    capacity_type  = string
    disk_size      = number
    ami_type       = string
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
  })
  default = {
    instance_types = ["t3.micro"]
    capacity_type  = "ON_DEMAND"
    disk_size      = 20
    ami_type       = "AL2023_x86_64_STANDARD"  # Amazon Linux 2023 (AL2 deprecated Nov 26, 2025)
    scaling_config = {
      desired_size = 2
      max_size     = 4
      min_size     = 1
    }
  }
}

# =============================================================================
# MONITORING CONFIGURATION
# =============================================================================

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring and logging"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

# =============================================================================
# SECURITY CONFIGURATION
# =============================================================================

variable "enable_flow_logs" {
  description = "Enable VPC flow logs"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable encryption for EBS volumes and secrets"
  type        = bool
  default     = true
}

variable "cluster_admin_arns" {
  description = "List of IAM user/role ARNs that should have admin access to the EKS cluster"
  type        = list(string)
  default     = []
}