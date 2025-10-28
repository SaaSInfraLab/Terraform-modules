# Terraform Modules Repository

A comprehensive, reusable Terraform modules library for deploying production-grade AWS EKS infrastructure with multi-tenancy support, monitoring, and security best practices.

## Architecture Overview

This repository contains modular, provider-agnostic Terraform modules designed to be called from separate environment repositories (dev, staging, production). Each module is self-contained and focuses on a specific concern.

### Module Dependency Graph

```
provider.tf (in calling environment)
    ↓
iam/                    (IAM roles: eks-cluster, eks-node, vpc-flow-logs, cloudwatch-agent)
    ↓
vpc/                    (VPC, subnets, NAT, IGW, security groups, flow logs)
    ↓
eks/                    (EKS cluster, managed node group, OIDC provider)
    ↓
├─ monitoring/          (CloudWatch logs, metric alarms, dashboards)
├─ security/            (Security group rules, network ACLs, network policies)
└─ multi-tenancy/       (Namespaces, RBAC, resource quotas, network policies)
```

## Modules

### 1. IAM Module (`iam/`)

Centralized IAM role management for all AWS services.

**Resources Created:**
- `aws_iam_role.eks_cluster` - Role for EKS control plane
- `aws_iam_role.eks_node` - Role for EC2 nodes
- `aws_iam_role.vpc_flow_logs` - Role for VPC Flow Logs to CloudWatch
- `aws_iam_role.cloudwatch_agent` - Role for CloudWatch agent on nodes

**Key Features:**
- Toggle role creation with `create_*` variables
- Automatic policy attachments (AWS managed + inline policies)
- All roles configurable and reusable across modules

**Outputs:**
- Role ARNs and names for reference in other modules

### 2. VPC Module (`vpc/`)

Complete VPC infrastructure with multi-AZ subnets, NAT gateways, and security groups.

**Resources Created:**
- `aws_vpc` - VPC with configurable CIDR
- `aws_subnet` - Public (3) and private (3) subnets across 3 AZs
- `aws_internet_gateway` - IGW for public subnets
- `aws_nat_gateway` + `aws_eip` - NAT gateways for private subnets
- `aws_route_table` - Public and private route tables
- `aws_security_group` - EKS cluster and node security groups
- `aws_security_group_rule` - Ingress/egress rules
- `aws_flow_log` - VPC Flow Logs to CloudWatch (optional)

**Key Features:**
- Multi-AZ design for HA
- Automatic CIDR subnetting using `cidrsubnet()`
- Deterministic subnet naming with `for_each` using AZ map
- Configurable NAT gateway count per AZ
- Optional VPC Flow Logs (requires IAM role from iam module)

**Dependencies:**
- `vpc_flow_logs_role_arn` from iam module (optional)

**File Organization:**
- `main.tf` - Locals for AZ mapping
- `vpc.tf` - VPC resource
- `subnets.tf` - Public and private subnets
- `igw_nat.tf` - IGW and NAT gateways
- `route_tables.tf` - Route table definitions
- `security_groups.tf` - SG group definitions
- `sg_rules.tf` - SG ingress/egress rules
- `flow_logs.tf` - VPC Flow Logs to CloudWatch

### 3. EKS Module (`eks/`)

Managed EKS cluster with auto-scaling node groups and IRSA support.

**Resources Created:**
- `aws_eks_cluster` - EKS control plane
- `aws_eks_node_group` - Managed node group with auto-scaling
- `aws_launch_template` - Custom launch template for nodes
- `aws_cloudwatch_log_group` - EKS cluster logs (optional)
- `aws_iam_openid_connect_provider` - OIDC provider for IRSA
- `aws_iam_instance_profile` - Instance profile for nodes

**Key Features:**
- Native implementation (no external module wrapper)
- Automatic AMI selection (latest EKS-optimized)
- IRSA support for pod-level IAM roles
- Custom user data with IMDSv2 enforcement
- EBS encryption enabled by default
- Cluster endpoint access controls (public + private)

**Dependencies:**
- `cluster_iam_role_arn` from iam module
- `node_iam_role_arn` from iam module
- VPC IDs and security groups from vpc module

**File Organization:**
- `main.tf` - Locals for node group naming
- `cluster.tf` - EKS cluster, log group, OIDC provider
- `node_group.tf` - Node group, launch template, instance profile

### 4. Monitoring Module (`monitoring/`)

CloudWatch Container Insights, metric alarms, and dashboards.

**Resources Created:**
- `aws_cloudwatch_log_group` - Container Insights log group (optional)
- `aws_cloudwatch_metric_alarm` - CPU, memory, pod metrics
- `aws_cloudwatch_dashboard` - EKS cluster visualization

**Key Features:**
- Container Insights for advanced monitoring
- Configurable metric alarms with thresholds
- Pre-built dashboard for cluster metrics
- Optional SNS notifications

**Dependencies:**
- `cluster_name` (string)
- `cloudwatch_agent_role_arn` from iam module (optional)

### 5. Security Module (`security/`)

Security group rules, network ACLs, and network policy enforcement.

**Resources Created:**
- `aws_security_group_rule` - Cluster API, kubelet, node communication rules
- `aws_network_acl` - Network ACL for EKS traffic
- `aws_network_acl_rule` - NACL rules (HTTPS, kubelet, ephemeral)
- `aws_security_group` - Network policy enforcement group (optional)

**Key Features:**
- Least-privilege ingress rules
- Network ACL for defense-in-depth
- Optional network policy SG for Calico/Cilium
- Configurable allowed CIDR blocks
- Pod security policy flags for future use

**Dependencies:**
- VPC security groups from vpc module

### 6. Multi-Tenancy Module (`multi-tenancy/`)

Kubernetes namespace isolation, RBAC, resource quotas, and IRSA per tenant.

**Resources Created:**
- `kubernetes_namespace` - Tenant namespace
- `kubernetes_resource_quota` - CPU, memory, pod, storage limits per tenant
- `kubernetes_network_policy` - Namespace-to-namespace isolation
- `kubernetes_service_account` - IRSA-enabled service accounts
- `kubernetes_role` - Tenant admin role
- `kubernetes_role_binding` - Bind role to service account

**Key Features:**
- Multi-tenant isolation via namespaces
- Resource quotas prevent tenant over-consumption
- Network policies for pod-level isolation
- IRSA support for per-tenant AWS permissions
- RBAC for tenant-scoped access control

**Note:** Requires Kubernetes provider configuration in calling environment.

**Dependencies:**
- `cluster_name` (string)
- Kubernetes cluster connectivity (kubeconfig)

## Usage

### Architecture Pattern: Centralized Modules + Environment Repos

This modules repository should be called from separate environment-specific repositories (not included in this repo).

### Example Calling Structure

```
terraform-modules/          (this repo)
├── iam/
├── vpc/
├── eks/
├── monitoring/
├── security/
└── multi-tenancy/

terraform-environments/     (separate repo)
├── dev/
│   ├── main.tf           (calls modules)
│   ├── provider.tf       (aws provider config)
│   ├── terraform.tf      (backend + required_providers)
│   └── dev.tfvars
├── staging/
│   ├── main.tf
│   ├── provider.tf
│   ├── terraform.tf
│   └── staging.tfvars
└── prod/
    ├── main.tf
    ├── provider.tf
    ├── terraform.tf
    └── prod.tfvars
```

### Complete Example: Deploying to Dev Environment

**Directory Structure:**
```
terraform-environments/dev/
├── main.tf
├── provider.tf
├── terraform.tf
└── dev.tfvars
```

**provider.tf** (Provider config belongs here, NOT in modules):
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
  }

  required_version = ">= 1.3"

  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_auth.cluster.token

  experiments {
    manifest_resource = true
  }
}

data "aws_eks_auth" "cluster" {
  name = module.eks.cluster_id
}
```

**main.tf** (Module composition):
```hcl
# IAM Roles
module "iam" {
  source = "git::https://github.com/your-org/terraform-modules.git//iam?ref=v1.0.0"

  create_eks_cluster_role  = true
  create_eks_node_role     = true
  create_vpc_flow_logs_role = true
  create_cloudwatch_agent_role = true

  name_prefix = var.name_prefix
  cluster_name = var.cluster_name
  tags        = local.tags
}

# VPC
module "vpc" {
  source = "git::https://github.com/your-org/terraform-modules.git//vpc?ref=v1.0.0"

  name_prefix = var.name_prefix
  cidr_block  = var.vpc_cidr
  azs         = var.availability_zones
  enable_flow_logs = true
  vpc_flow_logs_role_arn = module.iam.vpc_flow_logs_role_arn

  tags = local.tags
}

# EKS Cluster
module "eks" {
  source = "git::https://github.com/your-org/terraform-modules.git//eks?ref=v1.0.0"

  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  cluster_iam_role_arn = module.iam.eks_cluster_role_arn
  node_iam_role_arn = module.iam.eks_node_role_arn

  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids = module.vpc.public_subnet_ids
  cluster_security_group_id = module.vpc.eks_cluster_sg_id
  nodes_security_group_id = module.vpc.eks_nodes_sg_id

  desired_size = var.node_desired_size
  min_size     = var.node_min_size
  max_size     = var.node_max_size
  instance_types = var.node_instance_types

  tags = local.tags

  depends_on = [module.vpc]
}

# Monitoring
module "monitoring" {
  source = "git::https://github.com/your-org/terraform-modules.git//monitoring?ref=v1.0.0"

  cluster_name = module.eks.cluster_name
  enable_container_insights = true
  log_group_retention_days = 7
  enable_alarms = true

  tags = local.tags

  depends_on = [module.eks]
}

# Security
module "security" {
  source = "git::https://github.com/your-org/terraform-modules.git//security?ref=v1.0.0"

  vpc_id = module.vpc.vpc_id
  cluster_security_group_id = module.vpc.eks_cluster_sg_id
  nodes_security_group_id = module.vpc.eks_nodes_sg_id
  cluster_name = var.cluster_name
  allowed_cidr_blocks = var.allowed_cidr_blocks

  tags = local.tags

  depends_on = [module.vpc]
}

# Multi-Tenancy
module "multi_tenancy" {
  source = "git::https://github.com/your-org/terraform-modules.git//multi-tenancy?ref=v1.0.0"

  cluster_name = module.eks.cluster_name
  enable_rbac = true
  enable_namespace_isolation = true
  enable_service_accounts = true
  
  tenants = var.tenants

  tags = local.tags

  depends_on = [module.eks]
}
```

**dev.tfvars**:
```hcl
aws_region = "us-east-1"
environment = "dev"
name_prefix = "acme-dev"
cluster_name = "acme-dev-eks"
cluster_version = "1.28"

vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

node_desired_size = 2
node_min_size = 1
node_max_size = 5
node_instance_types = ["t3.medium"]

allowed_cidr_blocks = ["10.0.0.0/8"]

tenants = [
  {
    name                   = "team-platform"
    namespace              = "team-platform"
    cpu_limit              = "5"
    memory_limit           = "10Gi"
    pod_limit              = "100"
    storage_limit          = "50Gi"
    enable_network_policy  = true
  },
  {
    name                   = "team-data"
    namespace              = "team-data"
    cpu_limit              = "10"
    memory_limit           = "20Gi"
    pod_limit              = "150"
    storage_limit          = "100Gi"
    enable_network_policy  = true
  }
]

tags = {
  Project     = "Acme"
  Owner       = "Platform"
  CostCenter  = "Engineering"
}
```

### Deploy Steps

```bash
# 1. Clone environment repo
git clone https://github.com/your-org/terraform-environments.git
cd terraform-environments/dev

# 2. Initialize Terraform
terraform init

# 3. Plan
terraform plan -var-file=dev.tfvars -out=tfplan

# 4. Apply
terraform apply tfplan
```

## Module Development Guidelines

### Adding New Modules

1. Create module directory: `mkdir -p <module-name>`
2. Create required files:
   - `variables.tf` - Input variables
   - `main.tf` - Resource definitions
   - `outputs.tf` - Output values
3. **DO NOT** include provider blocks in modules
4. Use descriptive variable names and defaults
5. Add data sources for cross-resource references
6. Document all variables and outputs

### Best Practices

- **Provider-Agnostic**: Never hardcode provider configuration
- **Modular**: Each module should have a single responsibility
- **Configurable**: Use variables for all resource configuration
- **Safe Outputs**: Use `try()` for optional resource outputs
- **Semantic Naming**: Use clear, descriptive resource and variable names
- **Documentation**: Include descriptions for all variables and outputs
- **Dependencies**: Use `depends_on` for explicit relationships between resources

## Terraform Version Requirements

- Terraform >= 1.3
- AWS Provider >= 4.0
- Kubernetes Provider >= 2.20 (for multi-tenancy module)

## Backend Configuration

Each environment should configure its own S3 backend:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "<environment>/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

## Common Issues

### 1. Missing Provider Error During Validation

```
Error: Missing required provider registry.terraform.io/hashicorp/aws
```

**Solution:** This is expected for modules (they don't have providers). Initialize terraform in the calling environment where provider config exists.

### 2. Kubernetes Provider Not Found

```
Error: Missing required provider registry.terraform.io/hashicorp/kubernetes
```

**Solution:** Add Kubernetes provider to your calling environment's `terraform.tf` if using multi-tenancy module.

### 3. Cross-Module Reference Issues

**Solution:** Use module outputs explicitly:
```hcl
# Correct
vpc_id = module.vpc.vpc_id

# Incorrect
vpc_id = aws_vpc.main.id  # Won't work outside module
```

## Contributing

1. Follow module structure and naming conventions
2. Always include examples in module documentation
3. Test modules independently before committing
4. Update this README with changes
5. Use semantic versioning for releases

## License

[Your License Here]

## Support

For issues or questions, please open an issue in this repository.
