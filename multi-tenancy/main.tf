// Local variables for Kubernetes-safe labels
locals {
  # Convert tag values to be Kubernetes label compliant
  # Replace spaces with underscores, remove invalid chars
  k8s_safe_tags = {
    for k, v in var.tags : k => replace(replace(lower(v), " ", "_"), "/[^a-z0-9._-]/", "")
  }
}

// Kubernetes Namespace for each tenant
resource "kubernetes_namespace" "tenant" {
  for_each = { for tenant in var.tenants : tenant.name => tenant }

  metadata {
    name = each.value.namespace
    labels = merge(
      local.k8s_safe_tags,
      {
        tenant      = each.value.name
        environment = "production"
      }
    )
  }

  depends_on = [
    null_resource.cluster_ready
  ]
}

// Resource Quota per tenant (CPU, Memory, Pods)
resource "kubernetes_resource_quota" "tenant" {
  for_each = { for tenant in var.tenants : tenant.name => tenant }

  metadata {
    name      = "${each.value.name}-quota"
    namespace = kubernetes_namespace.tenant[each.value.name].metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = each.value.cpu_limit
      "requests.memory" = each.value.memory_limit
      "limits.cpu"      = each.value.cpu_limit
      "limits.memory"   = each.value.memory_limit
      "pods"            = each.value.pod_limit
      "requests.storage" = each.value.storage_limit
    }

    scope_selector {
      match_expression {
        operator       = "In"
        scope_name     = "PriorityClass"
        values         = ["default"]
      }
    }
  }

  depends_on = [
    kubernetes_namespace.tenant
  ]
}

// Network Policy for tenant isolation
resource "kubernetes_network_policy" "tenant_isolation" {
  for_each = {
    for tenant in var.tenants :
    tenant.name => tenant
    if tenant.enable_network_policy
  }

  metadata {
    name      = "${each.value.name}-network-policy"
    namespace = kubernetes_namespace.tenant[each.value.name].metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        tenant = each.value.name
      }
    }

    policy_types = ["Ingress", "Egress"]

    ingress {
      from {
        pod_selector {
          match_labels = {
            tenant = each.value.name
          }
        }
      }
    }

    egress {
      to {
        pod_selector {
          match_labels = {
            tenant = each.value.name
          }
        }
      }
      
      to {
        namespace_selector {
          match_labels = {
            name = "kube-system"
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = "53"
      }
    }
  }

  depends_on = [
    kubernetes_namespace.tenant
  ]
}

// Service Account for each tenant (IRSA)
resource "kubernetes_service_account" "tenant" {
  for_each = { for tenant in var.tenants : tenant.name => tenant }

  metadata {
    name      = "${each.value.name}-sa"
    namespace = kubernetes_namespace.tenant[each.value.name].metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${each.value.name}-role"
    }
  }

  depends_on = [
    kubernetes_namespace.tenant
  ]
}

// Role for tenant admin access
resource "kubernetes_role" "tenant_admin" {
  for_each = { for tenant in var.tenants : tenant.name => tenant }

  metadata {
    name      = "${each.value.name}-admin"
    namespace = kubernetes_namespace.tenant[each.value.name].metadata[0].name
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  depends_on = [
    kubernetes_namespace.tenant
  ]
}

// Role Binding for tenant admin
resource "kubernetes_role_binding" "tenant_admin" {
  for_each = { for tenant in var.tenants : tenant.name => tenant }

  metadata {
    name      = "${each.value.name}-admin-binding"
    namespace = kubernetes_namespace.tenant[each.value.name].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.tenant_admin[each.value.name].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.tenant[each.value.name].metadata[0].name
    namespace = kubernetes_namespace.tenant[each.value.name].metadata[0].name
  }

  depends_on = [
    kubernetes_role.tenant_admin
  ]
}

// Placeholder resource to ensure cluster is ready
resource "null_resource" "cluster_ready" {
  triggers = {
    cluster_id = var.cluster_name
  }
}

data "aws_caller_identity" "current" {}
