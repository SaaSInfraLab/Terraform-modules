variable "cluster_name" {
  description = "EKS cluster name for CloudWatch namespace"
  type        = string
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for EKS"
  type        = bool
  default     = true
}

variable "log_group_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 7
}

variable "enable_alarms" {
  description = "Enable CloudWatch alarms for EKS cluster"
  type        = bool
  default     = true
}

variable "alarm_sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  type        = string
  default     = ""
}

variable "node_cpu_threshold" {
  description = "CPU utilization threshold for node alarm (%)"
  type        = number
  default     = 80
}

variable "node_memory_threshold" {
  description = "Memory utilization threshold for node alarm (%)"
  type        = number
  default     = 80
}

variable "pod_cpu_threshold" {
  description = "CPU utilization threshold for pod alarm (%)"
  type        = number
  default     = 90
}

variable "cloudwatch_agent_role_arn" {
  description = "ARN of CloudWatch Agent IAM role (from iam module)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
