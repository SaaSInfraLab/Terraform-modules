# =============================================================================
# TENANT INFORMATION
# =============================================================================

output "tenant_namespaces" {
  description = "List of created tenant namespaces"
  value       = module.multi_tenancy.tenant_namespaces
}

output "tenant_names" {
  description = "List of tenant names"
  value       = [for tenant in var.tenants : tenant.name]
}

output "tenant_summary" {
  description = "Summary of tenant configurations"
  value = {
    for tenant in var.tenants : tenant.name => {
      namespace     = tenant.namespace
      cpu_limit     = tenant.cpu_limit
      memory_limit  = tenant.memory_limit
      pod_limit     = tenant.pod_limit
      storage_limit = tenant.storage_limit
      network_policy_enabled = tenant.enable_network_policy
    }
  }
}

# =============================================================================
# CLUSTER INFORMATION (from infrastructure)
# =============================================================================

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = data.terraform_remote_state.infrastructure.outputs.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster"
  value       = data.terraform_remote_state.infrastructure.outputs.cluster_endpoint
}

# =============================================================================
# KUBECTL COMMANDS
# =============================================================================

output "kubeconfig_update_command" {
  description = "Command to update kubeconfig for this cluster"
  value       = data.terraform_remote_state.infrastructure.outputs.kubeconfig_update_command
}

output "verification_commands" {
  description = "Commands to verify multi-tenant setup"
  value = {
    "Check namespaces"      = "kubectl get namespaces"
    "Check resource quotas" = "kubectl get resourcequotas --all-namespaces"
    "Check network policies" = "kubectl get networkpolicies --all-namespaces"
    "Check RBAC roles"      = "kubectl get roles --all-namespaces"
    "Check service accounts" = "kubectl get serviceaccounts --all-namespaces"
    "Describe tenant quota" = "kubectl describe resourcequota -n <tenant-namespace>"
  }
}

# =============================================================================
# TENANT ACCESS COMMANDS
# =============================================================================

output "tenant_access_commands" {
  description = "Commands to access each tenant namespace"
  value = {
    for tenant in var.tenants : tenant.name => {
      "Set context"     = "kubectl config set-context ${tenant.name} --cluster=${data.terraform_remote_state.infrastructure.outputs.cluster_name} --namespace=${tenant.namespace}"
      "Use context"     = "kubectl config use-context ${tenant.name}"
      "List resources"  = "kubectl get all -n ${tenant.namespace}"
      "Check quota"     = "kubectl describe resourcequota -n ${tenant.namespace}"
      "Check limits"    = "kubectl describe limitrange -n ${tenant.namespace}"
    }
  }
}