# CloudNative SaaS EKS Platform

![Platform Architecture](https://img.shields.io/badge/AWS-EKS-FF9900?style=for-the-badge&logo=amazon-aws)
![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?style=for-the-badge&logo=terraform)
![Kubernetes](https://img.shields.io/badge/Platform-Kubernetes-326CE5?style=for-the-badge&logo=kubernetes)
![Multi-Tenant](https://img.shields.io/badge/Architecture-Multi--Tenant-success?style=for-the-badge)

> **Pure reusable Terraform modules for multi-tenant SaaS infrastructure on AWS EKS. This repository contains modules only - for complete configuration examples, see [cloudnative-saas-eks](https://github.com/SaaSInfraLab/cloudnative-saas-eks).**

## 🏗️ Overview

This repository contains **pure reusable Terraform modules** for building multi-tenant SaaS infrastructure on AWS EKS. These modules are designed to be used from the [cloudnative-saas-eks](https://github.com/SaaSInfraLab/cloudnative-saas-eks) repository, which provides complete configuration examples and deployment guides.

### Available Modules

- **🌐 VPC**: Network foundation with public/private subnets, NAT gateways, and security groups
- **🔐 IAM**: Identity and access management with EKS cluster and node roles
- **☸️ EKS**: Kubernetes cluster with managed node groups and access control
- **🛡️ Security**: Security groups, network ACLs, and encryption
- **📊 Monitoring**: CloudWatch Container Insights and logging
- **🗄️ RDS**: PostgreSQL database with Secrets Manager integration
- **📦 ECR**: Container registry for Docker images
- **👥 Multi-Tenancy**: Tenant isolation with namespaces, quotas, and network policies

---

## 📁 Project Structure

```
Terraform-modules/
└── 📚 modules/                     # Reusable Terraform modules
    ├── vpc/                        # Network foundation
    ├── iam/                        # Identity & access management  
    ├── eks/                        # Kubernetes cluster
    ├── security/                   # Security groups & policies
    ├── monitoring/                 # Observability stack
    ├── rds/                        # RDS database
    ├── ecr/                        # Container registry
    └── multi-tenancy/              # Tenant isolation
```

> **Note**: This repository contains **pure reusable modules only**. For complete configuration examples and deployment guides, see [cloudnative-saas-eks](https://github.com/SaaSInfraLab/cloudnative-saas-eks).

---

## 🚀 Quick Start

### Prerequisites

```bash
# Required tools
- AWS CLI (configured)
- Terraform >= 1.0  
- kubectl

# Verify setup
aws sts get-caller-identity
terraform version
kubectl version --client
```

### Using the Modules

These modules are designed to be used from the [cloudnative-saas-eks](https://github.com/SaaSInfraLab/cloudnative-saas-eks) repository, which contains all configuration files and examples.

Example module usage:

```hcl
module "vpc" {
  source = "github.com/SaaSInfraLab/Terraform-modules//modules/vpc?ref=main"
  
  name_prefix = "my-vpc"
  vpc_cidr    = "10.0.0.0/16"
  # ... other variables
}
```

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
- **EC2**: m7i-flex.large instances (free tier eligible, 1 vCPU, 8GB RAM)
- **EBS**: 30GB free storage per month
- **CloudWatch**: 5GB log ingestion free
- **EKS**: $0.10/hour cluster cost only
- **RDS**: db.t4g.micro (ARM-based, free tier eligible)

### Production Optimizations
- **Spot Instances**: Up to 90% cost savings
- **Auto Scaling**: Scale nodes based on demand
- **Storage Classes**: GP2 → GP3 for better price/performance
- **Log Retention**: Optimize CloudWatch costs

**Estimated Monthly Cost**: 
- **Development**: ~$15-20/month (free tier eligible with m7i-flex.large nodes)
- **Production**: ~$300-500 (optimized)

**Note**: Development environment uses `m7i-flex.large` nodes (free tier eligible) which provide ~29 pods/node capacity, significantly better than t3.micro (4 pods/node).

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

## 🔧 Module Usage

Each module is self-contained and documented. See individual module directories for:
- Input variables (`variables.tf`)
- Output values (`outputs.tf`)
- Resource definitions (`main.tf`)

For complete configuration examples, see [cloudnative-saas-eks](https://github.com/SaaSInfraLab/cloudnative-saas-eks).

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

For complete deployment guides, configuration examples, and usage instructions, see:
- **[cloudnative-saas-eks](https://github.com/SaaSInfraLab/cloudnative-saas-eks)**: Complete configuration repository with examples and deployment guides

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

- **Issues**: [GitHub Issues](https://github.com/SaaSInfraLab/Terraform-modules/issues)
- **Discussions**: [GitHub Discussions](https://github.com/SaaSInfraLab/Terraform-modules/discussions)

---

<div align="center">

**🌟 Star this repository if it helped you build better SaaS infrastructure! 🌟**

[![GitHub stars](https://img.shields.io/github/stars/SaaSInfraLab/Terraform-modules?style=social)](https://github.com/SaaSInfraLab/Terraform-modules/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/SaaSInfraLab/Terraform-modules?style=social)](https://github.com/SaaSInfraLab/Terraform-modules/network/members)

Built with ❤️ for the SaaS community

</div>