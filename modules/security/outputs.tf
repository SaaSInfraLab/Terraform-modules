output "network_acl_id" {
  description = "ID of the EKS Network ACL"
  value       = aws_network_acl.eks_nacl.id
}

output "network_policy_sg_id" {
  description = "Security group ID for network policy enforcement"
  value       = try(aws_security_group.network_policy[0].id, null)
}

output "cluster_api_https_rule_id" {
  description = "ID of the HTTPS cluster API security group rule"
  value       = aws_security_group_rule.cluster_api_https.id
}

output "nodes_to_cluster_rule_id" {
  description = "ID of the nodes-to-cluster security group rule"
  value       = aws_security_group_rule.nodes_to_cluster.id
}

output "cluster_to_nodes_kubelet_rule_id" {
  description = "ID of the cluster-to-nodes kubelet security group rule"
  value       = aws_security_group_rule.cluster_to_nodes_kubelet.id
}
