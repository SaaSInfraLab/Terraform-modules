variable "vpc_id" {
  description = "VPC ID for security group resources"
  type        = string
}

variable "cluster_security_group_id" {
  description = "EKS cluster security group ID (from vpc module)"
  type        = string
}

variable "nodes_security_group_id" {
  description = "EKS nodes security group ID (from vpc module)"
  type        = string
}

variable "enable_pod_security_policy" {
  description = "Enable Pod Security Policy enforcement"
  type        = bool
  default     = false
}

variable "enable_network_policy" {
  description = "Enable network policy support (requires CNI plugin)"
  type        = bool
  default     = true
}

variable "enable_encryption_in_transit" {
  description = "Enable encryption in transit for pods"
  type        = bool
  default     = true
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access cluster API"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
