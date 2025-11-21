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
  default     = "1.32"
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

variable "cluster_access_principals" {
  description = "List of IAM principal ARNs (users or roles) that should have cluster access. Prefer IAM roles over users."
  type        = list(string)
  default     = []
}

variable "cluster_access_config" {
  description = <<-EOT
    Map of principal ARN to access configuration. Allows different access levels per principal.
    If not specified for a principal, defaults to cluster admin.
    
    Example:
    cluster_access_config = {
      "arn:aws:iam::123456789012:role/AdminRole" = {
        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        access_scope = {
          type       = "cluster"
          namespaces = []
        }
      }
    }
  EOT
  type = map(object({
    policy_arn = string
    access_scope = object({
      type       = string
      namespaces = list(string)
    })
  }))
  default = {}
}

variable "auto_include_executor" {
  description = "Automatically include the IAM principal running Terraform in cluster access"
  type        = bool
  default     = true
}

variable "create_eks_access_roles" {
  description = "Whether to create IAM roles for EKS cluster access (Admin, Developer, Viewer)"
  type        = bool
  default     = true
}

variable "eks_admin_trusted_principals" {
  description = "List of IAM principal ARNs that can assume the EKS Admin role"
  type        = list(string)
  default     = []
}

variable "eks_developer_trusted_principals" {
  description = "List of IAM principal ARNs that can assume the EKS Developer role"
  type        = list(string)
  default     = []
}

variable "eks_viewer_trusted_principals" {
  description = "List of IAM principal ARNs that can assume the EKS Viewer role"
  type        = list(string)
  default     = []
}