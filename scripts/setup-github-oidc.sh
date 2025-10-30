# =============================================================================
# GITHUB ACTIONS OIDC SETUP FOR AWS
# =============================================================================

# Step 1: Create OIDC Provider for GitHub Actions
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1

# Step 2: Create IAM Role for GitHub Actions
aws iam create-role \
  --role-name GitHubActions-SaaSInfraLab-Role \
  --assume-role-policy-document file://github-actions-trust-policy.json

# Step 3: Attach necessary policies to the role
aws iam attach-role-policy \
  --role-name GitHubActions-SaaSInfraLab-Role \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# Step 4: Add EKS access for the GitHub Actions role
aws eks create-access-entry \
  --cluster-name saasinfralab-dev \
  --region us-east-1 \
  --principal-arn arn:aws:iam::821368347884:role/GitHubActions-SaaSInfraLab-Role

aws eks associate-access-policy \
  --cluster-name saasinfralab-dev \
  --region us-east-1 \
  --principal-arn arn:aws:iam::821368347884:role/GitHubActions-SaaSInfraLab-Role \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
  --access-scope type=cluster