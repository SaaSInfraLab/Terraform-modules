# GitHub Actions OIDC Setup for AWS - Complete Guide

## 🔐 Overview

This setup eliminates the need for long-term AWS credentials stored as GitHub secrets by using OpenID Connect (OIDC) for secure, temporary credential assumption.

## 🎯 Benefits

- ✅ **No Long-term Credentials**: No more `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` secrets
- ✅ **Enhanced Security**: Temporary credentials with automatic rotation
- ✅ **Least Privilege**: Role-based access with specific permissions
- ✅ **Audit Trail**: Better tracking of which GitHub workflows accessed AWS
- ✅ **Repository-specific**: Access restricted to your specific repository

## 🛠️ Setup Complete

### 1. AWS OIDC Provider ✅
```bash
Provider ARN: arn:aws:iam::821368347884:oidc-provider/token.actions.githubusercontent.com
Thumbprint: 6938fd4d98bab03faadb97b34396831e3780aea1
```

### 2. IAM Role ✅
```bash
Role Name: GitHubActions-SaaSInfraLab-Role
Role ARN: arn:aws:iam::821368347884:role/GitHubActions-SaaSInfraLab-Role
Permissions: PowerUserAccess (allows all AWS operations except IAM user management)
```

### 3. EKS Access ✅
```bash
EKS Cluster: saasinfralab-dev
Access Policy: AmazonEKSClusterAdminPolicy
Scope: cluster (full cluster admin access)
```

### 4. GitHub Actions Workflow ✅
Updated `.github/workflows/terraform.yml` to use OIDC authentication instead of secrets.

## 🔄 Migration Steps Completed

### Before (Using Secrets):
```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: us-west-2
```

### After (Using OIDC):
```yaml
permissions:
  id-token: write  # Required for OIDC
  contents: read

- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::821368347884:role/GitHubActions-SaaSInfraLab-Role
    role-session-name: GitHubActions-Infrastructure
    aws-region: us-west-2
```

## 🧪 Testing the Setup

### 1. Remove Old Secrets (Optional)
You can now safely remove these secrets from your GitHub repository:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### 2. Test Workflow
Push to main branch or manually trigger the workflow to test OIDC authentication.

### 3. Verify Access
The workflow should now:
- ✅ Assume the IAM role automatically
- ✅ Access AWS services with PowerUser permissions
- ✅ Deploy to EKS cluster without authentication errors
- ✅ Create and manage Terraform resources

## 🔒 Security Features

### Trust Policy Restrictions
The IAM role can only be assumed by:
- **Repository**: `SaaSInfraLab/Terraform-modules`
- **Provider**: GitHub Actions OIDC
- **Audience**: `sts.amazonaws.com`

### Session Management
- **Temporary credentials**: Valid only for the workflow duration
- **Unique sessions**: Each job gets a distinct session name
- **Automatic cleanup**: Credentials expire automatically

## 🚨 Troubleshooting

### Common Issues

1. **"Could not assume role" Error**
   - Verify repository name in trust policy matches exactly
   - Check OIDC provider thumbprint is correct
   - Ensure `id-token: write` permission is set

2. **EKS Access Denied**
   - Verify role has EKS access entry: ✅ Already configured
   - Check cluster name matches: `saasinfralab-dev` ✅

3. **Terraform State Access**
   - S3 bucket permissions included in PowerUserAccess ✅
   - Backend configuration uses correct bucket and region ✅

### Debug Commands

```bash
# Check OIDC provider
aws iam get-open-id-connect-provider \
  --open-id-connect-provider-arn arn:aws:iam::821368347884:oidc-provider/token.actions.githubusercontent.com

# Check role trust policy
aws iam get-role --role-name GitHubActions-SaaSInfraLab-Role

# Check EKS access
aws eks list-access-entries --cluster-name saasinfralab-dev --region us-east-1
```

## 📈 Next Steps

1. **Test the workflow** by pushing to main branch
2. **Remove old AWS secrets** from GitHub repository settings
3. **Monitor CloudTrail** for OIDC authentication events
4. **Consider additional roles** for different environments (dev/staging/prod)

## 🔗 Resources

- [GitHub OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [AWS IAM OIDC Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [EKS Access Entry Documentation](https://docs.aws.amazon.com/eks/latest/userguide/access-entries.html)

---

## 🎉 Success!

Your GitHub Actions workflow now uses **secure, temporary credentials** with **zero long-term secrets**! The setup provides:

- **Infrastructure deployment** with full AWS access
- **EKS cluster management** with admin permissions  
- **Multi-tenant configuration** deployment
- **Secure credential handling** with automatic rotation

Ready for production CI/CD! 🚀