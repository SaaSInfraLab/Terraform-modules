# =============================================================================
# CLUSTER INFORMATION
# =============================================================================

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "Version of the EKS cluster"
  value       = module.eks.cluster_version
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

# =============================================================================
# NETWORKING INFORMATION
# =============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

# =============================================================================
# SECURITY GROUPS
# =============================================================================

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.vpc.eks_cluster_sg_id
}

output "nodes_security_group_id" {
  description = "Security group ID attached to the EKS worker nodes"
  value       = module.vpc.eks_nodes_sg_id
}

# =============================================================================
# IAM ROLES
# =============================================================================

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.iam.eks_cluster_role_arn
}

output "node_iam_role_arn" {
  description = "IAM role ARN of the EKS worker nodes"
  value       = module.iam.eks_node_role_arn
}

# =============================================================================
# AWS REGION
# =============================================================================

output "aws_region" {
  description = "AWS region where infrastructure is deployed"
  value       = var.aws_region
}

# =============================================================================
# KUBECONFIG COMMAND
# =============================================================================

output "kubeconfig_update_command" {
  description = "Command to update kubeconfig for this cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}