# Development Environment Example

This directory contains a complete example of how to use the Terraform modules to deploy a production-ready EKS cluster with multi-tenancy support.

## Architecture

This example deploys the following AWS infrastructure:

```
┌─────────────────────────────────────────────────────────────────┐
│                    AWS Account (us-east-1)                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │          VPC: 10.0.0.0/16 (3 AZs)                       │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │                                                            │   │
│  │  Public Subnets (NAT Gateways):                          │   │
│  │  ├─ 10.0.1.0/24 (us-east-1a)                            │   │
│  │  ├─ 10.0.2.0/24 (us-east-1b)                            │   │
│  │  └─ 10.0.3.0/24 (us-east-1c)                            │   │
│  │                                                            │   │
│  │  Private Subnets (EKS Nodes):                            │   │
│  │  ├─ 10.0.11.0/24 (us-east-1a)                           │   │
│  │  ├─ 10.0.12.0/24 (us-east-1b)                           │   │
│  │  └─ 10.0.13.0/24 (us-east-1c)                           │   │
│  │                                                            │   │
│  │  ┌─────────────────────────────────────────────────────┐ │   │
│  │  │ EKS Cluster: acmeapp-dev                           │ │   │
│  │  ├─────────────────────────────────────────────────────┤ │   │
│  │  │ Control Plane (Managed by AWS)                      │ │   │
│  │  │ ├─ Kubernetes 1.28                                 │ │   │
│  │  │ ├─ Multi-AZ deployment                             │ │   │
│  │  │ └─ Container Insights enabled                      │ │   │
│  │  │                                                     │ │   │
│  │  │ Managed Node Group:                                │ │   │
│  │  │ ├─ Desired: 2 nodes (t3.medium)                    │ │   │
│  │  │ ├─ Min: 1, Max: 5 (auto-scaling)                   │ │   │
│  │  │ └─ Deployed across 3 AZs                           │ │   │
│  │  │                                                     │ │   │
│  │  │ Tenants (Namespaces):                              │ │   │
│  │  │ ├─ team-platform (5 CPU, 10Gi RAM, 100 pods)       │ │   │
│  │  │ ├─ team-data (10 CPU, 20Gi RAM, 150 pods)          │ │   │
│  │  │ └─ team-analytics (8 CPU, 16Gi RAM, 120 pods)      │ │   │
│  │  │                                                     │ │   │
│  │  └─────────────────────────────────────────────────────┘ │   │
│  │                                                            │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ IAM Roles (Centralized)                                  │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │ ├─ EKS Cluster Role                                      │   │
│  │ ├─ EKS Node Role                                         │   │
│  │ ├─ VPC Flow Logs Role                                    │   │
│  │ └─ CloudWatch Agent Role                                 │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Monitoring & Observability                               │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │ ├─ CloudWatch Container Insights (7 day retention)       │   │
│  │ ├─ CloudWatch Metric Alarms (CPU, Memory, Pods)          │   │
│  │ └─ CloudWatch Dashboard                                  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Files

- `terraform.tf` - Terraform version requirements and remote backend configuration
- `provider.tf` - AWS and Kubernetes provider configuration
- `main.tf` - Module composition showing all modules being called
- `variables.tf` - All input variables with defaults
- `dev.tfvars` - Development environment variable values
- `outputs.tf` - (Optional) Can add outputs from child modules here

## Prerequisites

1. **AWS Account** with appropriate permissions (EC2, EKS, IAM, CloudWatch, VPC)
2. **AWS CLI** configured with credentials for your dev account
3. **Terraform** >= 1.3
4. **kubectl** for managing the cluster post-deployment
5. **Git** access to the modules repository

## Quick Start

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Plan Deployment

```bash
terraform plan -var-file=dev.tfvars -out=tfplan
```

This will show all resources to be created:
- 1 VPC with subnets, NAT, IGW, flow logs
- 1 EKS cluster with managed node group
- IAM roles and policies
- CloudWatch monitoring and alarms
- Security groups and network ACLs
- Kubernetes namespaces and RBAC for 3 tenants

### 3. Apply Configuration

```bash
terraform apply tfplan
```

**Deployment time:** 15-20 minutes (mostly waiting for EKS cluster creation)

### 4. Verify Deployment

```bash
# Get cluster credentials
aws eks update-kubeconfig \
  --name acmeapp-dev \
  --region us-east-1

# Verify cluster connectivity
kubectl get nodes

# Check Container Insights metrics
# Navigate to CloudWatch > Container Insights > Cluster Performance

# List tenant namespaces
kubectl get namespaces

# View tenant quotas
kubectl get resourcequotas -A

# Check IRSA pod role mapping
kubectl describe sa team-platform-sa -n team-platform
```

## Customization

### Change Cluster Size

Edit `dev.tfvars`:

```hcl
node_desired_size  = 3  # Increase from 2
node_max_size      = 10 # Increase from 5
node_instance_types = ["t3.large"]  # Larger instances
```

Then re-apply:

```bash
terraform plan -var-file=dev.tfvars -out=tfplan
terraform apply tfplan
```

### Add New Tenant

Edit `dev.tfvars` and add to the `tenants` list:

```hcl
tenants = [
  # ... existing tenants ...
  {
    name                  = "team-ml"
    namespace             = "team-ml"
    cpu_limit             = "16"
    memory_limit          = "32Gi"
    pod_limit             = "200"
    storage_limit         = "500Gi"
    enable_network_policy = true
  }
]
```

Apply changes:

```bash
terraform apply -var-file=dev.tfvars
```

### Modify Network Security

Edit `dev.tfvars` to restrict API access:

```hcl
allowed_cidr_blocks = [
  "203.0.113.0/24",  # Your office
  "198.51.100.0/24"  # Your VPN
]
```

### Increase Monitoring Retention

Edit `dev.tfvars`:

```hcl
log_retention_days = 30  # Increase from 7 for better audit trail
```

## Deployment Steps Explained

When you run `terraform apply`, the following happens in order:

1. **IAM Module** - Creates 4 centralized IAM roles for cluster/nodes/logs/monitoring
2. **VPC Module** - Creates VPC, subnets across 3 AZs, NAT gateways, security groups, and flow logs
3. **EKS Module** - Creates EKS cluster, managed node group, OIDC provider (this takes ~15 min)
4. **Monitoring Module** - Creates CloudWatch log groups, alarms, and dashboards
5. **Security Module** - Creates security group rules and network ACLs
6. **Multi-Tenancy Module** - Creates Kubernetes namespaces, quotas, RBAC, and network policies

## Post-Deployment Tasks

### 1. Deploy Applications to Tenants

```bash
# Deploy to team-platform namespace
kubectl apply -f my-app-manifests.yaml -n team-platform

# Verify quota usage
kubectl describe quota team-platform-quota -n team-platform
```

### 2. Configure IRSA for Tenant Applications

```bash
# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Annotate service account for IRSA
kubectl annotate serviceaccount team-platform-sa \
  eks.amazonaws.com/role-arn=arn:aws:iam::${ACCOUNT_ID}:role/team-platform-role \
  -n team-platform --overwrite
```

### 3. Set Up Monitoring Alerts

Navigate to AWS CloudWatch:
- View Container Insights dashboard: **CloudWatch > Container Insights > Cluster Performance**
- Check alarms: **CloudWatch > Alarms** for CPU, memory, pod metrics
- Enable SNS notifications for critical alarms

### 4. Configure VPC Flow Logs

Flow logs are automatically sent to CloudWatch:
```bash
# Query flow logs for debugging network issues
aws logs start-query \
  --log-group-name "/aws/vpc/flowlogs/acmeapp-dev" \
  --start-time $(date -d '1 hour ago' +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | stats count() by action'
```

## Scaling in Production

For production deployment (`examples/prod`), adjust:

```hcl
# Production sizing (larger cluster)
node_desired_size  = 5
node_min_size      = 3
node_max_size      = 20
node_instance_types = ["t3.large", "t3.xlarge"]

# Production monitoring (longer retention)
log_retention_days = 90

# Production networking (restricted access)
allowed_cidr_blocks = [
  "10.0.0.0/8"  # Your organization's internal network
]

# Production tenants (larger resource allocations)
tenants = [
  {
    name                  = "team-platform"
    namespace             = "team-platform"
    cpu_limit             = "20"
    memory_limit          = "50Gi"
    pod_limit             = "500"
    storage_limit         = "500Gi"
    enable_network_policy = true
  },
  # ... more tenants ...
]
```

## Troubleshooting

### Cluster Creation Fails

Check IAM permissions:
```bash
aws iam get-user
aws iam list-attached-user-policies --user-name <your-username>
```

Required policies:
- `AmazonEKSClusterPolicy`
- `AmazonEC2FullAccess`
- `IAMFullAccess`

### Nodes Not Joining Cluster

Check CloudWatch logs:
```bash
aws logs tail /aws/eks/acmeapp-dev/cluster --follow
```

Common issues:
- Security group rules blocking kubelet (port 10250)
- IAM role missing required policies
- Insufficient EC2 capacity in AZ

### Terraform Apply Timeout

EKS cluster creation can take 15+ minutes. If it times out:

```bash
# Check cluster status
aws eks describe-cluster --name acmeapp-dev --query 'cluster.status'

# Wait for cluster to be ACTIVE, then run terraform apply again
terraform apply -var-file=dev.tfvars
```

## Cleanup

To destroy all resources:

```bash
terraform destroy -var-file=dev.tfvars
```

**Warning:** This will delete:
- EKS cluster and all running applications
- VPC and all subnets
- RDS instances (if configured)
- Persistent volumes
- All CloudWatch logs and alarms

Ensure you have backups before destroying!

## Monitoring Costs

The development environment typically costs:

| Resource | Quantity | Monthly Cost |
|----------|----------|--------------|
| EKS Control Plane | 1 | $73 |
| t3.medium instances | 2-5 | $20-50 |
| NAT Gateway | 1 | $32 |
| Data transfer (NAT) | 1 GB/month | $0.05 |
| CloudWatch Logs | 7 days retention | $5-10 |
| **Total** | | **$130-170** |

For production (5 nodes, 90-day retention): **$250-400/month**

Optimize costs with:
- Reserved Instances (30% savings)
- Spot Instances for non-critical workloads (60-70% savings)
- Log retention policies (shorter retention = lower cost)

## Next Steps

1. Update `dev.tfvars` with your specific values
2. Run `terraform plan` to review changes
3. Run `terraform apply` to deploy
4. Configure kubectl access
5. Deploy applications to tenant namespaces
6. Monitor via CloudWatch dashboards

## Support & Documentation

- **Terraform Modules**: See `../../README.md`
- **EKS Documentation**: https://docs.aws.amazon.com/eks/
- **Kubernetes**: https://kubernetes.io/docs/
- **Terraform**: https://www.terraform.io/docs/

## References

- [AWS EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [Kubernetes Multi-Tenancy Guide](https://kubernetes.io/docs/concepts/security/multi-tenancy/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
