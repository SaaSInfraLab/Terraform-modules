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
