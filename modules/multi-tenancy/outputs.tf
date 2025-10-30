output "tenant_namespaces" {
  description = "Map of tenant names to their namespace names"
  value = {
    for tenant_name, ns in kubernetes_namespace.tenant :
    tenant_name => ns.metadata[0].name
  }
}

output "tenant_quotas" {
  description = "Map of tenant names to their resource quota IDs"
  value = {
    for tenant_name, rq in kubernetes_resource_quota.tenant :
    tenant_name => {
      name      = rq.metadata[0].name
      namespace = rq.metadata[0].namespace
    }
  }
}

output "tenant_service_accounts" {
  description = "Map of tenant names to their service account names"
  value = {
    for tenant_name, sa in kubernetes_service_account.tenant :
    tenant_name => {
      name      = sa.metadata[0].name
      namespace = sa.metadata[0].namespace
    }
  }
}

output "tenant_network_policies" {
  description = "Map of tenant names to their network policy IDs (if enabled)"
  value = {
    for tenant_name, np in kubernetes_network_policy.tenant_isolation :
    tenant_name => {
      name      = np.metadata[0].name
      namespace = np.metadata[0].namespace
    }
  }
}

output "tenant_admin_roles" {
  description = "Map of tenant names to their admin role names"
  value = {
    for tenant_name, role in kubernetes_role.tenant_admin :
    tenant_name => {
      name      = role.metadata[0].name
      namespace = role.metadata[0].namespace
    }
  }
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = var.cluster_name
}

output "rbac_enabled" {
  description = "Whether RBAC is enabled"
  value       = var.enable_rbac
}

output "namespace_isolation_enabled" {
  description = "Whether namespace isolation is enabled"
  value       = var.enable_namespace_isolation
}

output "service_accounts_enabled" {
  description = "Whether service accounts for IRSA are enabled"
  value       = var.enable_service_accounts
}
