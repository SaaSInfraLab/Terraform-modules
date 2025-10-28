output "container_insights_log_group_name" {
  description = "CloudWatch log group name for Container Insights"
  value       = try(aws_cloudwatch_log_group.container_insights[0].name, null)
}

output "container_insights_log_group_arn" {
  description = "CloudWatch log group ARN for Container Insights"
  value       = try(aws_cloudwatch_log_group.container_insights[0].arn, null)
}

output "dashboard_url" {
  description = "URL to CloudWatch dashboard"
  value       = try("https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.id}#dashboards:name=${aws_cloudwatch_dashboard.eks[0].dashboard_name}", null)
}

output "node_cpu_alarm_name" {
  description = "Name of node CPU utilization alarm"
  value       = try(aws_cloudwatch_metric_alarm.node_cpu[0].alarm_name, null)
}

output "node_memory_alarm_name" {
  description = "Name of node memory utilization alarm"
  value       = try(aws_cloudwatch_metric_alarm.node_memory[0].alarm_name, null)
}

output "pod_cpu_alarm_name" {
  description = "Name of pod CPU utilization alarm"
  value       = try(aws_cloudwatch_metric_alarm.pod_cpu[0].alarm_name, null)
}
