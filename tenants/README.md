# =============================================================================
# TENANTS PHASE README
# =============================================================================

# Phase 2: Multi-Tenant Kubernetes Setup

This directory contains the Terraform configuration for deploying multi-tenant Kubernetes resources on the EKS cluster created in Phase 1.

## What Gets Deployed

### 🏢 Multi-Tenancy Features
- **Namespaces**: Isolated environments for each tenant
- **Resource Quotas**: CPU, memory, storage, and pod limits per tenant
- **RBAC**: Role-based access control for namespace-level permissions
- **Network Policies**: Traffic isolation between tenants
- **Service Accounts**: IAM roles for service accounts (IRSA) integration

### 👥 Default Tenants
1. **saasinfralab-platform**: Core platform services (20 CPU, 40Gi RAM)
2. **team-data**: Data processing workloads (10 CPU, 20Gi RAM)
3. **team-analytics**: Analytics and ML workloads (15 CPU, 30Gi RAM)

## Prerequisites

### Phase 1 Must Be Complete
This phase requires the infrastructure from Phase 1 to be successfully deployed:

```bash
# Verify Phase 1 is complete
cd ../infrastructure
terraform output cluster_name
```

### Required Tools
- AWS CLI configured and authenticated
- kubectl installed
- Terraform >= 1.0

### Cluster Endpoint Resilience
**Note:** This module automatically fetches the current cluster endpoint directly from AWS, ensuring it always uses the latest endpoint even if the remote state file has stale data. This prevents connection errors when the cluster endpoint changes (e.g., after cluster updates or recreations).

## Quick Start

### Deploy Multi-Tenancy

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan -var-file="tenants.tfvars"

# Deploy tenant resources
terraform apply -var-file="tenants.tfvars"

# Verify deployment
kubectl get namespaces
kubectl get resourcequotas --all-namespaces
```

### Verify Tenant Setup

```bash
# Check all namespaces
kubectl get namespaces

# View resource quotas
kubectl get resourcequotas --all-namespaces

# Check network policies
kubectl get networkpolicies --all-namespaces

# Inspect specific tenant
kubectl describe namespace team-data
kubectl describe resourcequota -n team-data
```

## Configuration

### Main Configuration File: `tenants.tfvars`

```hcl
tenants = [
  {
    name                  = "team-data"
    namespace             = "team-data"
    cpu_limit             = "10"           # 10 CPU cores
    memory_limit          = "20Gi"         # 20GB RAM
    pod_limit             = 150            # Maximum pods
    storage_limit         = "100Gi"        # 100GB storage
    enable_network_policy = true           # Traffic isolation
  }
  # ... more tenants
]
```

### Tenant Resource Allocation

| Tenant | CPU Limit | Memory Limit | Pod Limit | Storage Limit | Purpose |
|--------|-----------|--------------|-----------|---------------|---------|
| Platform | 20 cores | 40Gi | 200 | 200Gi | Core services |
| Data | 10 cores | 20Gi | 150 | 100Gi | Data processing |
| Analytics | 15 cores | 30Gi | 180 | 150Gi | ML/Analytics |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    EKS Cluster (from Phase 1)                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ saasinfralab-   │  │   team-data     │  │ team-analytics  │ │
│  │   platform      │  │   namespace     │  │   namespace     │ │
│  │   namespace     │  │                 │  │                 │ │
│  │                 │  │ CPU: 10 cores   │  │ CPU: 15 cores   │ │
│  │ CPU: 20 cores   │  │ RAM: 20Gi       │  │ RAM: 30Gi       │ │
│  │ RAM: 40Gi       │  │ Pods: 150       │  │ Pods: 180       │ │
│  │ Pods: 200       │  │ Storage: 100Gi  │  │ Storage: 150Gi  │ │
│  │ Storage: 200Gi  │  └─────────────────┘  └─────────────────┘ │
│  └─────────────────┘                                            │
│                                                                 │
│  Network Policies: ✓    RBAC: ✓    Resource Quotas: ✓         │
└─────────────────────────────────────────────────────────────────┘
```

## Tenant Management

### Adding New Tenants

1. **Update Configuration**: Add tenant to `tenants.tfvars`
2. **Apply Changes**: Run `terraform apply`
3. **Verify Setup**: Check namespace and quotas

```hcl
# Add new tenant to tenants.tfvars
{
  name                  = "team-ml"
  namespace             = "team-ml"
  cpu_limit             = "8"
  memory_limit          = "16Gi"
  pod_limit             = 120
  storage_limit         = "80Gi"
  enable_network_policy = true
}
```

### Tenant Access

Each tenant gets:
- **Dedicated namespace** for resource isolation
- **Resource quotas** to prevent resource monopolization
- **Network policies** for traffic isolation
- **RBAC roles** for namespace-level access control

### Setting Up Kubectl Contexts

```bash
# Set context for specific tenant
kubectl config set-context team-data \
  --cluster=saasinfralab-dev \
  --namespace=team-data

# Use tenant context
kubectl config use-context team-data

# Now all kubectl commands operate in team-data namespace
kubectl get pods  # Shows pods in team-data namespace only
```

## Monitoring & Observability

### Resource Usage Monitoring

```bash
# Check resource consumption by namespace
kubectl top nodes
kubectl top pods --all-namespaces

# View quota usage for specific tenant
kubectl describe resourcequota -n team-data

# Check available resources
kubectl describe limitrange -n team-data
```

### Common Commands

```bash
# List all tenant namespaces
kubectl get namespaces | grep -E "(platform|team-)"

# Check quota status across all tenants
kubectl get resourcequotas --all-namespaces -o wide

# View network policies
kubectl get networkpolicies --all-namespaces

# Check tenant service accounts
kubectl get serviceaccounts --all-namespaces
```

## Security Features

### Network Isolation
- **Default Deny**: All inter-namespace traffic blocked by default
- **Explicit Allow**: Network policies define allowed traffic patterns
- **Ingress/Egress Control**: Fine-grained traffic control

### Resource Isolation
- **CPU Limits**: Prevent CPU starvation between tenants
- **Memory Limits**: Avoid memory pressure across tenants
- **Storage Quotas**: Control persistent volume usage
- **Pod Limits**: Prevent pod sprawl

### Access Control
- **RBAC**: Namespace-level role-based access
- **Service Accounts**: Dedicated accounts per tenant
- **IRSA Integration**: AWS IAM integration for service accounts

## Troubleshooting

### Common Issues

**Quota exceeded errors:**
```bash
# Check current quota usage
kubectl describe resourcequota -n <tenant-namespace>

# Increase limits in tenants.tfvars and apply
terraform apply -var-file="tenants.tfvars"
```

**Network connectivity issues:**
```bash
# Check network policies
kubectl get networkpolicies -n <tenant-namespace>

# Test connectivity between pods
kubectl exec -n <namespace> <pod-name> -- ping <target-ip>
```

**Permission denied errors:**
```bash
# Check RBAC permissions
kubectl auth can-i <verb> <resource> --namespace=<tenant-namespace>

# View role bindings
kubectl get rolebindings -n <tenant-namespace>
```

### Resource Monitoring

```bash
# Check resource usage
kubectl top pods -n <tenant-namespace>

# View resource events
kubectl get events -n <tenant-namespace> --sort-by='.lastTimestamp'

# Check pod status
kubectl get pods -n <tenant-namespace> -o wide
```

## Outputs

After successful deployment, this phase provides:

- **tenant_namespaces**: List of created namespaces
- **tenant_summary**: Resource allocation summary
- **verification_commands**: Commands to verify setup
- **tenant_access_commands**: Commands for tenant access

## Files in this Directory

- **main.tf**: Multi-tenancy module configuration
- **terraform.tf**: AWS and Kubernetes provider setup
- **variables.tf**: Input variable definitions
- **outputs.tf**: Output values and commands
- **tenants.tfvars.example**: Example tenant configurations
- **README.md**: This documentation

**Note**: This module is designed to be used as a child module. Backend configuration should be defined in the root module that calls this module, not in this module itself.

## Next Steps

1. **Deploy Applications**: Deploy workloads to tenant namespaces
2. **Set Up Monitoring**: Configure per-tenant dashboards
3. **Implement GitOps**: Set up CI/CD pipelines per tenant
4. **Scale Resources**: Adjust quotas based on usage patterns

---

**⚠️ Important**: This phase depends on the infrastructure phase. Ensure Phase 1 is successfully deployed before running this configuration.