# ============================================================================
# Development Environment Configuration
# ============================================================================

aws_region   = "us-east-1"
environment  = "dev"
project_name = "SaasInfalab"
name_prefix  = "saasinfalab-dev"

# ============================================================================
# Cluster Configuration
# ============================================================================
cluster_name    = "saasinfalab-dev"
cluster_version = "1.29"

# ============================================================================
# Network Configuration
# ============================================================================
vpc_cidr = "10.0.0.0/16"

availability_zones = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c"
]

# ============================================================================
# Node Group Configuration
# ============================================================================
node_desired_size  = 2
node_min_size      = 1
node_max_size      = 5
node_instance_types = [
  "t3.micro"
]

# ============================================================================
# Security Configuration
# ============================================================================
# Allow cluster API access from your office/VPN
allowed_cidr_blocks = [
  "0.0.0.0/0"  # Change this to your office/VPN CIDR for production!
]

enable_network_policies = true

# ============================================================================
# Monitoring Configuration
# ============================================================================
enable_container_insights = true
log_retention_days        = 7
enable_security_alarms    = true

# ============================================================================
# Multi-Tenancy Configuration
# ============================================================================
# Define tenants with their resource limits
tenants = [
  {
    name                  = "saasinfalab-platform"
    namespace             = "saasinfalab-platform"
    cpu_limit             = "5"
    memory_limit          = "10Gi"
    pod_limit             = "100"
    storage_limit         = "50Gi"
    enable_network_policy = true
  },
  {
    name                  = "team-data"
    namespace             = "team-data"
    cpu_limit             = "10"
    memory_limit          = "20Gi"
    pod_limit             = "150"
    storage_limit         = "100Gi"
    enable_network_policy = true
  },
  {
    name                  = "team-analytics"
    namespace             = "team-analytics"
    cpu_limit             = "8"
    memory_limit          = "16Gi"
    pod_limit             = "120"
    storage_limit         = "200Gi"
    enable_network_policy = true
  }
]

# ============================================================================
# Tags
# ============================================================================
tags = {
  Owner       = "Platform Engineering"
  CostCenter  = "Engineering"
  Compliance  = "SOC2"
  Backups     = "Daily"
}
