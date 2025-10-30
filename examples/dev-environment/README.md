# =============================================================================
# DEVELOPMENT ENVIRONMENT EXAMPLE
# =============================================================================

# Complete Working Example for SaaS Infrastructure Lab

This directory contains a complete, ready-to-deploy example configuration for setting up a development environment with EKS and multi-tenancy.

## What You Get

### 🏗️ Infrastructure
- **EKS Cluster**: Kubernetes 1.31 with public endpoint access
- **Node Groups**: 2 t3.micro instances (free tier eligible)
- **VPC**: Custom VPC with 3 AZs, public/private subnets
- **Security**: Proper security groups, IAM roles, encryption
- **Monitoring**: CloudWatch Container Insights

### 👥 Multi-Tenancy
- **3 Tenant Teams**: Platform, Data, Analytics
- **Resource Isolation**: CPU, memory, storage quotas per tenant
- **Network Isolation**: Network policies between namespaces
- **RBAC**: Role-based access control per namespace

## Quick Start

### Option 1: GitHub Actions (Recommended)

1. **Configure Repository Secrets** (if not already done):
   ```
   AWS_ACCESS_KEY_ID=your_aws_access_key  
   AWS_SECRET_ACCESS_KEY=your_aws_secret_key
   ```

2. **Deploy via GitHub Actions**:
   - Push to main branch for automatic deployment
   - Or use manual workflow trigger in GitHub Actions tab

### Option 2: Manual Deployment

```bash
# From the repository root directory

# Step 1: Deploy Infrastructure
cd infrastructure
terraform init
terraform plan -var-file="../examples/dev-environment/infrastructure.tfvars"
terraform apply -var-file="../examples/dev-environment/infrastructure.tfvars"

# Step 2: Deploy Tenants
cd ../tenants
terraform init
terraform plan -var-file="../examples/dev-environment/tenants.tfvars"
terraform apply -var-file="../examples/dev-environment/tenants.tfvars"
```

## Manual Deployment Details

### Step 1: Deploy Infrastructure

```bash
# Navigate to infrastructure directory
cd ../../infrastructure

# Initialize and deploy
terraform init
terraform plan -var-file="../examples/dev-environment/infrastructure.tfvars"
terraform apply -var-file="../examples/dev-environment/infrastructure.tfvars"

# Update kubeconfig
aws eks update-kubeconfig --name saasinfralab-dev --region us-east-1
```

### Step 2: Deploy Tenants

```bash
# Navigate to tenants directory
cd ../tenants

# Initialize and deploy
terraform init
terraform plan -var-file="../examples/dev-environment/tenants.tfvars"
terraform apply -var-file="../examples/dev-environment/tenants.tfvars"
```

### Step 3: Verify Deployment

```bash
# Check cluster
kubectl get nodes

# Check namespaces
kubectl get namespaces | grep -E "(platform|team-)"

# Check resource quotas
kubectl get resourcequotas --all-namespaces

# Check a specific tenant
kubectl describe namespace team-data
kubectl describe resourcequota -n team-data
```

## Configuration Details

### Infrastructure Settings

```hcl
# Core settings
cluster_name = "saasinfralab-dev"
cluster_version = "1.31"
vpc_cidr = "10.0.0.0/16"

# Free tier optimized with Amazon Linux 2023
node_group_config = {
  instance_types = ["t3.micro"]
  ami_type = "AL2023_x86_64_STANDARD"  # Updated from AL2 (deprecated Nov 26, 2025)
  scaling_config = {
    desired_size = 2
    max_size = 4
    min_size = 1
  }
}
```

### Tenant Allocation

| Tenant | Purpose | CPU | Memory | Pods | Storage |
|--------|---------|-----|---------|------|---------|
| Platform | Core services | 20 cores | 40Gi | 200 | 200Gi |
| Data | Data processing | 10 cores | 20Gi | 150 | 100Gi |
| Analytics | ML/Analytics | 15 cores | 30Gi | 180 | 150Gi |

## Testing the Setup

### Deploy Sample Applications

```bash
# Deploy nginx to data team namespace
kubectl create deployment nginx --image=nginx -n team-data

# Check if it respects resource quotas
kubectl get pods -n team-data
kubectl describe resourcequota -n team-data

# Test network isolation
kubectl run test-pod --image=busybox -n team-analytics -- sleep 3600
kubectl exec -n team-analytics test-pod -- ping <pod-ip-in-team-data>
# Should fail due to network policy
```

### Monitor Resource Usage

```bash
# Check cluster resource usage
kubectl top nodes
kubectl top pods --all-namespaces

# Check tenant-specific usage
kubectl top pods -n team-data
kubectl describe resourcequota -n team-data
```

## Cost Optimization

This example is optimized for cost:

- **t3.micro instances**: Free tier eligible (750 hours/month)
- **Minimal nodes**: Start with 2, scale to 4 max
- **GP2 storage**: Cost-effective EBS volumes
- **7-day log retention**: Minimal CloudWatch costs
- **Single NAT Gateway**: Shared across all private subnets

**Estimated monthly cost**: ~$60-100 (after free tier)

## Scaling for Production

To scale this example for production:

### 1. Infrastructure Changes

```hcl
# In infrastructure.tfvars
node_group_config = {
  instance_types = ["t3.medium", "t3.large"]
  capacity_type = "SPOT"  # Use spot instances
  scaling_config = {
    desired_size = 3
    max_size = 10
    min_size = 2
  }
}

# Disable public endpoint
cluster_endpoint_config = {
  private_access = true
  public_access = false
  public_access_cidrs = []
}
```

### 2. Tenant Changes

```hcl
# In tenants.tfvars - Add more tenants
{
  name = "team-frontend"
  namespace = "team-frontend"
  cpu_limit = "8"
  memory_limit = "16Gi"
  pod_limit = 120
  storage_limit = "80Gi"
  enable_network_policy = true
}
```

### 3. Security Enhancements

- Enable Pod Security Standards
- Implement Admission Controllers
- Set up external secrets management
- Configure ingress with TLS

## Cleanup

```bash
# Destroy everything
cd examples/dev-environment
./destroy.sh

# Or manually:
cd ../../tenants && terraform destroy -var-file="../examples/dev-environment/tenants.tfvars"
cd ../infrastructure && terraform destroy -var-file="../examples/dev-environment/infrastructure.tfvars"
```

## Troubleshooting

### Common Issues

1. **Node groups taking long**: EKS node provisioning can take 10-15 minutes
2. **Kubectl connection issues**: Run `aws eks update-kubeconfig`
3. **Resource quota errors**: Check tenant limits in configuration
4. **Network policy blocking traffic**: Review network policy rules

### Debug Commands

```bash
# Check cluster status
aws eks describe-cluster --name saasinfralab-dev

# Check node group status
aws eks describe-nodegroup --cluster-name saasinfralab-dev --nodegroup-name <nodegroup-name>

# Check AWS authentication
aws sts get-caller-identity

# Check kubectl config
kubectl config current-context
kubectl cluster-info
```

---

This example provides a solid foundation for understanding and deploying the SaaS Infrastructure Lab architecture. Modify the configurations as needed for your specific requirements!