variable "name_prefix" {
  description = "Prefix for all IAM role names"
  type        = string
  default     = "saaslab"
}

variable "cluster_name" {
  description = "EKS cluster name (used in role naming)"
  type        = string
  default     = "eks"
}

variable "tags" {
  description = "Additional tags to apply to IAM roles"
  type        = map(string)
  default     = {}
}

variable "create_eks_cluster_role" {
  description = "Whether to create the EKS cluster IAM role"
  type        = bool
  default     = true
}

variable "create_eks_node_role" {
  description = "Whether to create the EKS node IAM role"
  type        = bool
  default     = true
}

variable "create_vpc_flow_logs_role" {
  description = "Whether to create the VPC Flow Logs IAM role"
  type        = bool
  default     = true
}

variable "create_cloudwatch_agent_role" {
  description = "Whether to create the CloudWatch Agent IAM role"
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

variable "aws_region" {
  description = "AWS region (used for assume role condition)"
  type        = string
  default     = ""
}