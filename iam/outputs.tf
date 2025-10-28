output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = try(aws_iam_role.eks_cluster[0].arn, null)
}

output "eks_cluster_role_name" {
  description = "Name of the EKS cluster IAM role"
  value       = try(aws_iam_role.eks_cluster[0].name, null)
}

output "eks_node_role_arn" {
  description = "ARN of the EKS node IAM role"
  value       = try(aws_iam_role.eks_node[0].arn, null)
}

output "eks_node_role_name" {
  description = "Name of the EKS node IAM role"
  value       = try(aws_iam_role.eks_node[0].name, null)
}

output "vpc_flow_logs_role_arn" {
  description = "ARN of the VPC Flow Logs IAM role"
  value       = try(aws_iam_role.vpc_flow_logs[0].arn, null)
}

output "vpc_flow_logs_role_name" {
  description = "Name of the VPC Flow Logs IAM role"
  value       = try(aws_iam_role.vpc_flow_logs[0].name, null)
}

output "cloudwatch_agent_role_arn" {
  description = "ARN of the CloudWatch Agent IAM role"
  value       = try(aws_iam_role.cloudwatch_agent[0].arn, null)
}

output "cloudwatch_agent_role_name" {
  description = "Name of the CloudWatch Agent IAM role"
  value       = try(aws_iam_role.cloudwatch_agent[0].name, null)
}
