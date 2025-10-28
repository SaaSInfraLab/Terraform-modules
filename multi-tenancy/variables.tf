variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "enable_rbac" {
  description = "Enable RBAC for multi-tenancy"
  type        = bool
  default     = true
}

variable "enable_namespace_isolation" {
  description = "Enable namespace-level resource quotas and limits"
  type        = bool
  default     = true
}

variable "tenants" {
  description = "List of tenant configurations"
  type = list(object({
    name                      = string
    namespace                 = string
    cpu_limit                 = string
    memory_limit              = string
    pod_limit                 = number
    storage_limit             = string
    enable_network_policy     = bool
  }))
  default = []
}

variable "enable_service_accounts" {
  description = "Create service accounts per tenant for IRSA"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
