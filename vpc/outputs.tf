output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = [for s in aws_subnet.private : s.id]
}

output "nat_gateway_ids" {
  description = "IDs of NAT gateways"
  value       = aws_nat_gateway.nat[*].id
}

output "eks_cluster_sg_id" {
  description = "Security group id for EKS cluster"
  value       = aws_security_group.eks_cluster.id
}

output "eks_nodes_sg_id" {
  description = "Security group id for EKS worker nodes"
  value       = aws_security_group.eks_nodes.id
}

output "public_route_table_id" {
  description = "Public route table id"
  value       = aws_route_table.public.id
}

output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log resource (if enabled)"
  value       = try(aws_flow_log.vpc[0].id, null)
}

output "vpc_flow_logs_role_arn" {
  description = "ARN of the IAM role used for VPC Flow Logs (passed from iam module)"
  value       = var.vpc_flow_logs_role_arn
}

output "vpc_flow_log_log_group_arn" {
  description = "ARN of the CloudWatch Log Group used for VPC Flow Logs"
  value       = try(aws_cloudwatch_log_group.vpc_flow_logs[0].arn, null)
}

output "vpc_flow_log_log_group_name" {
  description = "Name of the CloudWatch Log Group used for VPC Flow Logs"
  value       = try(aws_cloudwatch_log_group.vpc_flow_logs[0].name, null)
}
