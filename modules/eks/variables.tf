variable "cluster_iam_role_arn" {
  description = "ARN of the IAM role for the EKS cluster (from iam module)"
  type        = string
}

variable "node_iam_role_arn" {
  description = "ARN of the IAM role for EKS worker nodes (from iam module)"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane"
  type        = string
  default     = "1.27"
}

variable "vpc_id" {
  description = "VPC id where EKS will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet ids (for worker nodes)"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet ids (for load balancers)"
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "Security group id for EKS control plane"
  type        = string
}

variable "nodes_security_group_id" {
  description = "Security group id for EKS worker nodes"
  type        = string
}

variable "node_group_name" {
  description = "Name for the EKS managed node group"
  type        = string
  default     = "default"
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 3
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 2
}

variable "node_instance_types" {
  description = "List of instance types for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_disk_size" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 20
}

variable "node_labels" {
  description = "Key-value map of Kubernetes labels to apply to nodes"
  type        = map(string)
  default     = {}
}

variable "node_taints" {
  description = "List of Kubernetes taints to apply to nodes"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "cluster_endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks allowed to access public API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_enabled_log_types" {
  description = "List of control plane logging types to enable (api, audit, authenticator, controllerManager, scheduler)"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "create_cluster_log_group" {
  description = "Whether to create CloudWatch log group for cluster logs"
  type        = bool
  default     = true
}

variable "cluster_log_retention_days" {
  description = "Number of days to retain cluster logs"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

