# CloudNative SaaS EKS Platform

![Platform Architecture](https://img.shields.io/badge/AWS-EKS-FF9900?style=for-the-badge&logo=amazon-aws)
![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?style=for-the-badge&logo=terraform)
![Kubernetes](https://img.shields.io/badge/Platform-Kubernetes-326CE5?style=for-the-badge&logo=kubernetes)
![Multi-Tenant](https://img.shields.io/badge/Architecture-Multi--Tenant-success?style=for-the-badge)

> **Production-ready, multi-tenant SaaS infrastructure on AWS EKS with complete isolation, security, and cost optimization.**

## ⚠️ Important Update - Amazon Linux 2023

**This repository has been updated to use Amazon Linux 2023** due to Amazon Linux 2 support ending on **November 26, 2025**. All configurations now use `AL2023_x86_64_STANDARD` AMI type. See [migration guide](docs/amazon-linux-2023-migration.md) for details.

## 🏗️ Architecture Overview

This platform provides a complete multi-tenant SaaS infrastructure solution built on AWS EKS, designed for teams that need secure tenant isolation, resource governance, and scalable operations.

### Key Features

- **🚀 Two-Phase Deployment**: Clean separation of infrastructure and application concerns
- **🏢 Multi-Tenancy**: Complete tenant isolation with resource quotas and network policies  
- **🛡️ Security First**: RBAC, network policies, encryption, and IAM integration
- **💰 Cost Optimized**: Free tier compatible with smart resource allocation
- **📊 Observable**: Built-in monitoring, logging, and alerting
- **🔧 Production Ready**: Follows AWS and Kubernetes best practices

---

## 📁 Project Structure

```
cloudnative-saas-eks/
├── 📚 modules/                     # Reusable Terraform modules
│   ├── vpc/                        # Network foundation
│   ├── iam/                        # Identity & access management  
│   ├── eks/                        # Kubernetes cluster
│   ├── security/                   # Security groups & policies
│   ├── monitoring/                 # Observability stack
│   └── multi-tenancy/              # Tenant isolation
│
├── 🏗️ infrastructure/              # Phase 1: Core AWS Resources
│   ├── main.tf                     # Infrastructure composition
│   ├── variables.tf                # Configuration parameters
│   ├── outputs.tf                  # Resource information
│   ├── terraform.tf                # Terraform/provider requirements
│   ├── backend.tf                  # State management
│   ├── infrastructure.tfvars.example
│   └── README.md                   # Phase 1 documentation
│
├── 👥 tenants/                     # Phase 2: Multi-Tenancy  
│   ├── main.tf                     # Tenant configuration
│   ├── terraform.tf                # Terraform/provider requirements
│   ├── variables.tf                # Tenant parameters
│   ├── outputs.tf                  # Tenant information
│   ├── backend.tf                  # State references
│   ├── tenants.tfvars.example
│   └── README.md                   # Phase 2 documentation
│
├── 💡 examples/
│   └── dev-environment/            # Complete working example
│       ├── infrastructure.tfvars   # Example infrastructure config
│       ├── tenants.tfvars          # Example tenant config  
│       └── README.md               # Deployment guide
│
├── 🚀 .github/workflows/           # CI/CD automation
│   └── CI-CD.yml               # GitHub Actions workflow
│
└── 📖 docs/                             # Documentation
    ├── github-actions-oidc-complete.md  # Quick setup for OIDC
    └── github-actions-setup.md          # Quick start guide for github actions
```

---

## 🚀 Quick Start

### Prerequisites

```bash
# Required tools
- AWS CLI (configured)
- Terraform >= 1.0  
- kubectl
- GitHub repository with Actions enabled

# Verify setup
aws sts get-caller-identity
terraform version
kubectl version --client
```

### GitHub Actions Deployment (Recommended)

This repository includes a complete GitHub Actions workflow for automated deployment:

#### 1. Repository Setup
```bash
# Fork or clone this repository to your GitHub account
git clone <your-repository-url>
cd terraform-modules
```

#### 2. Configure GitHub Secrets
In your GitHub repository, go to Settings → Secrets and variables → Actions and add:

```
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
```

#### 3. Automated Deployment Options

**Option A: Push to Main Branch**
```bash
# Any push to main branch will automatically:
# 1. Plan and validate Terraform
# 2. Deploy infrastructure phase
# 3. Deploy tenants phase
git push origin main
```

**Option B: Manual Workflow Trigger**
1. Go to GitHub Actions tab in your repository
2. Select "Terraform CI/CD" workflow
3. Click "Run workflow"
4. Choose action: `plan`, `apply`, or `destroy`

#### 4. Monitoring Deployment
- View progress in GitHub Actions tab
- Each phase runs separately for clear visibility
- Automatic state management between phases

### Manual Deployment (Advanced)

For local development or custom deployment scenarios:

```bash
# Phase 1: Infrastructure
cd infrastructure
terraform init
terraform apply -var-file="../examples/dev-environment/infrastructure.tfvars"

# Phase 2: Tenants  
cd ../tenants
terraform init
terraform apply -var-file="../examples/dev-environment/tenants.tfvars"

# Verify deployment
kubectl get nodes
kubectl get namespaces
```

### CI/CD Workflow Features

- **✅ Automated Validation**: Format, validate, and plan checks
- **🔄 Two-Phase Deployment**: Infrastructure → Tenants with proper dependencies
- **🛡️ Safe Destruction**: Tenants destroyed before infrastructure
- **📊 State Management**: Automatic state sharing between phases  
- **🔐 Secure**: Uses GitHub secrets for AWS credentials
- **📝 Detailed Logs**: Full visibility into deployment process

---

## 🏢 Multi-Tenant Architecture

### Default Tenant Configuration

| Tenant | Purpose | CPU | Memory | Pods | Storage | Use Case |
|--------|---------|-----|---------|------|---------|----------|
| **Platform** | Core services | 20 cores | 40Gi | 200 | 200Gi | Infrastructure services |
| **Data Team** | Data processing | 10 cores | 20Gi | 150 | 100Gi | ETL, databases |
| **Analytics** | ML/Analytics | 15 cores | 30Gi | 180 | 150Gi | ML models, analytics |

### Isolation Features

- **🔐 Network Isolation**: Network policies prevent cross-tenant traffic
- **📊 Resource Quotas**: CPU, memory, storage limits per tenant
- **👤 RBAC**: Namespace-level access control
- **🏷️ Service Accounts**: IAM roles for service accounts (IRSA)
- **🔍 Monitoring**: Per-tenant resource usage tracking

---

## 💰 Cost Optimization

### Free Tier Compatible
- **EC2**: t3.micro instances (750 hours/month free)
- **EBS**: 30GB free storage per month
- **CloudWatch**: 5GB log ingestion free
- **EKS**: $0.10/hour cluster cost only

### Production Optimizations
- **Spot Instances**: Up to 90% cost savings
- **Auto Scaling**: Scale nodes based on demand
- **Storage Classes**: GP2 → GP3 for better price/performance
- **Log Retention**: Optimize CloudWatch costs

**Estimated Monthly Cost**: 
- **Development**: ~$75-100 (free tier)
- **Production**: ~$300-500 (optimized)

---

## 📊 Monitoring & Observability

### Built-in Monitoring
- **CloudWatch Container Insights**: Cluster and pod metrics
- **VPC Flow Logs**: Network traffic analysis  
- **EKS Control Plane Logs**: API server, scheduler, controller logs
- **Resource Quotas Monitoring**: Per-tenant usage tracking

### Dashboards
- Cluster overview and health
- Per-tenant resource utilization
- Cost allocation by tenant
- Security events and violations

---

## 🛡️ Security Features

### Infrastructure Security
- **Encryption**: EBS volumes, secrets at rest
- **Network Security**: Private subnets, security groups
- **IAM**: Least privilege access policies
- **VPC Flow Logs**: Network monitoring

### Kubernetes Security  
- **Pod Security Standards**: Replace deprecated PSPs
- **Network Policies**: Traffic isolation
- **RBAC**: Fine-grained permissions
- **Service Mesh Ready**: Istio integration support

---

## 🔧 Configuration

### Infrastructure Configuration
```hcl
# infrastructure.tfvars
cluster_name = "saasinfralab-prod"
cluster_version = "1.31"
vpc_cidr = "10.0.0.0/16"

node_group_config = {
  instance_types = ["t3.medium", "t3.large"]
  capacity_type = "SPOT"
  scaling_config = {
    desired_size = 3
    max_size = 10  
    min_size = 2
  }
}
```

### Tenant Configuration
```hcl
# tenants.tfvars
tenants = [
  {
    name = "production-api"
    namespace = "prod-api"
    cpu_limit = "50"
    memory_limit = "100Gi"
    pod_limit = 500
    storage_limit = "1Ti"
    enable_network_policy = true
  }
]
```

---

## 🎯 Use Cases

### SaaS Platforms
- **Multi-tenant applications** with complete isolation
- **Per-customer environments** with resource governance
- **Cost allocation** and usage tracking per tenant

### Enterprise Teams
- **Department isolation** with shared infrastructure
- **Development/staging/prod** environment management
- **Resource governance** and cost control

### Consulting/Agencies
- **Client-dedicated environments** on shared infrastructure
- **Project-based** resource allocation
- **Rapid environment** provisioning and teardown

---

## 📚 Documentation

- **[Getting Started](docs/getting-started.md)**: Step-by-step setup guide
- **[Architecture](docs/architecture.md)**: Detailed system design
- **[Infrastructure Phase](infrastructure/README.md)**: Phase 1 documentation  
- **[Tenants Phase](tenants/README.md)**: Phase 2 documentation
- **[Examples](examples/dev-environment/README.md)**: Working examples
- **[Troubleshooting](docs/troubleshooting.md)**: Common issues and solutions

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🆘 Support

- **Issues**: [GitHub Issues](../../issues)
- **Discussions**: [GitHub Discussions](../../discussions)
- **Documentation**: [docs/](docs/)

---

<div align="center">

**🌟 Star this repository if it helped you build better SaaS infrastructure! 🌟**

[![GitHub stars](https://img.shields.io/github/stars/SaaSInfraLab/cloudnative-saas-eks?style=social)](../../stargazers)
[![GitHub forks](https://img.shields.io/github/forks/SaaSInfraLab/cloudnative-saas-eks?style=social)](../../network/members)

Built with ❤️ for the SaaS community

</div>
