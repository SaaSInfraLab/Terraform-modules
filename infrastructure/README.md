# =============================================================================
# INFRASTRUCTURE PHASE README
# =============================================================================

# Phase 1: Core AWS Infrastructure

This directory contains the Terraform configuration for deploying the core AWS infrastructure components required for a multi-tenant SaaS platform on EKS.

## What Gets Deployed

### 🏗️ Core Infrastructure
- **VPC**: Custom VPC with public/private subnets across 3 availability zones
- **EKS Cluster**: Kubernetes control plane with version 1.31
- **Node Groups**: Managed worker nodes with Amazon Linux 2023 (AL2 deprecated Nov 26, 2025)
- **IAM**: Roles and policies for EKS cluster, nodes, and service accounts

### 🛡️ Security
- **Security Groups**: Properly configured for EKS cluster and worker nodes
- **Network ACLs**: Additional network-level security
- **VPC Flow Logs**: Network traffic monitoring
- **Encryption**: EBS volumes and secrets encryption

### 📊 Monitoring
- **CloudWatch**: Container Insights for EKS monitoring
- **Log Groups**: Centralized logging for cluster and applications
- **Alarms**: Automated alerting for critical metrics

## Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- kubectl

### Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan -var-file="infrastructure.tfvars"

# Deploy infrastructure
terraform apply -var-file="infrastructure.tfvars"

# Update kubeconfig
aws eks update-kubeconfig --name saasinfralab-dev --region us-east-1

# Verify cluster
kubectl get nodes
```

## Configuration

### Main Configuration File: `infrastructure.tfvars`

```hcl
# Core settings
aws_region  = "us-east-1"
environment = "dev"

# EKS cluster
cluster_name    = "saasinfralab-dev"
cluster_version = "1.32"

# Network settings
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# Node groups (Free tier optimized)
node_group_config = {
  instance_types = ["t3.micro"]
  capacity_type  = "ON_DEMAND"
  scaling_config = {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }
}
```

## Outputs

After successful deployment, this phase outputs:

- **cluster_name**: EKS cluster name
- **cluster_endpoint**: Kubernetes API server endpoint
- **cluster_certificate_authority_data**: CA certificate for cluster access
- **vpc_id**: VPC identifier
- **subnet_ids**: Public and private subnet identifiers
- **security_group_ids**: EKS cluster and node security groups
- **iam_role_arns**: IAM roles for cluster and nodes

These outputs are consumed by the **tenants/** phase for multi-tenancy setup.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                           VPC (10.0.0.0/16)                │
├─────────────────────────────────────────────────────────────┤
│  AZ-1a          │  AZ-1b          │  AZ-1c          │
│ ┌─────────────┐ │ ┌─────────────┐ │ ┌─────────────┐ │
│ │Public Subnet│ │ │Public Subnet│ │ │Public Subnet│ │
│ │  (NAT GW)   │ │ │             │ │ │             │ │
│ └─────────────┘ │ └─────────────┘ │ └─────────────┘ │
│ ┌─────────────┐ │ ┌─────────────┐ │ ┌─────────────┐ │
│ │Private      │ │ │Private      │ │ │Private      │ │
│ │Subnet       │ │ │Subnet       │ │ │Subnet       │ │
│ │(EKS Nodes)  │ │ │(EKS Nodes)  │ │ │(EKS Nodes)  │ │
│ └─────────────┘ │ └─────────────┘ │ └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
         │                    │                    │
    ┌────────────┐      ┌──────────┐      ┌─────────────┐
    │ EKS Control│      │CloudWatch│      │   Security  │
    │   Plane    │      │Monitoring│      │   Groups    │
    └────────────┘      └──────────┘      └─────────────┘
```

## Cost Optimization

- **t3.micro instances**: Free tier eligible
- **Shared NAT Gateway**: Single NAT for cost reduction
- **GP2 storage**: Cost-effective EBS volumes
- **7-day log retention**: Minimal CloudWatch costs

## Next Steps

Once infrastructure is deployed:

1. **Verify Cluster**: `kubectl get nodes`
2. **Deploy Tenants**: Move to `../tenants/` directory
3. **Run Tests**: Deploy sample applications
4. **Monitor**: Check CloudWatch dashboards

## Troubleshooting

### Common Issues

**Node groups not ready:**
```bash
# Check node group status
aws eks describe-nodegroup --cluster-name saasinfralab-dev --nodegroup-name <node-group-name>

# Wait for nodes
kubectl get nodes -w
```

**IAM permission issues:**
```bash
# Check your AWS identity
aws sts get-caller-identity

# Verify EKS access
aws eks describe-cluster --name saasinfralab-dev
```

**Terraform state issues:**
```bash
# Refresh state
terraform refresh -var-file="infrastructure.tfvars"

# Check outputs
terraform output
```

## Files in this Directory

- **main.tf**: Main infrastructure configuration
- **variables.tf**: Input variable definitions
- **outputs.tf**: Output values for next phase
- **terraform.tf**: Terraform and provider requirements
- **backend.tf**: State backend configuration
- **README.md**: This documentation

**Note**: Example configuration files are available in `examples/dev-environment/infrastructure.tfvars`

---

**⚠️ Important**: This phase must complete successfully before deploying the tenants phase, as it provides essential cluster information required for Kubernetes resource provisioning.