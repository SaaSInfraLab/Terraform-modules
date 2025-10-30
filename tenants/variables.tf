# =============================================================================
# CORE CONFIGURATION
# =============================================================================

variable "aws_region" {
  description = "AWS region where infrastructure is deployed"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# =============================================================================
# TENANT CONFIGURATION
# =============================================================================

variable "tenants" {
  description = "List of tenant configurations for multi-tenancy"
  type = list(object({
    name                  = string
    namespace             = string
    cpu_limit             = string
    memory_limit          = string
    pod_limit             = number
    storage_limit         = string
    enable_network_policy = bool
  }))
  default = [
    {
      name                  = "saasinfralab-platform"
      namespace             = "saasinfralab-platform"
      cpu_limit             = "20"
      memory_limit          = "40Gi"
      pod_limit             = 200
      storage_limit         = "200Gi"
      enable_network_policy = true
    },
    {
      name                  = "team-data"
      namespace             = "team-data"
      cpu_limit             = "10"
      memory_limit          = "20Gi"
      pod_limit             = 150
      storage_limit         = "100Gi"
      enable_network_policy = true
    },
    {
      name                  = "team-analytics"
      namespace             = "team-analytics"
      cpu_limit             = "15"
      memory_limit          = "30Gi"
      pod_limit             = 180
      storage_limit         = "150Gi"
      enable_network_policy = true
    }
  ]
}

# =============================================================================
# ADVANCED CONFIGURATION
# =============================================================================

variable "enable_pod_security_policies" {
  description = "Enable Pod Security Policies for additional security"
  type        = bool
  default     = false
}

variable "enable_monitoring_per_tenant" {
  description = "Enable per-tenant monitoring and alerting"
  type        = bool
  default     = true
}

variable "default_storage_class" {
  description = "Default storage class for persistent volumes"
  type        = string
  default     = "gp2"
}