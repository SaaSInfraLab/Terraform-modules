// CloudWatch Log Group for Container Insights
resource "aws_cloudwatch_log_group" "container_insights" {
  count             = var.enable_container_insights ? 1 : 0
  name              = "/aws/containerinsights/${var.cluster_name}/performance"
  retention_in_days = var.log_group_retention_days

  tags = merge(
    var.tags,
    { Name = "/aws/containerinsights/${var.cluster_name}/performance" }
  )
}

// CloudWatch Alarm - Node CPU Utilization
resource "aws_cloudwatch_metric_alarm" "node_cpu" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.cluster_name}-node-cpu-utilization"
  alarm_description   = "Alert when node CPU utilization is high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = var.node_cpu_threshold
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    ClusterName = var.cluster_name
  }

  tags = merge(
    var.tags,
    { Name = "${var.cluster_name}-node-cpu-utilization" }
  )
}

// CloudWatch Alarm - Node Memory Utilization
resource "aws_cloudwatch_metric_alarm" "node_memory" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.cluster_name}-node-memory-utilization"
  alarm_description   = "Alert when node memory utilization is high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "node_memory_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = var.node_memory_threshold
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    ClusterName = var.cluster_name
  }

  tags = merge(
    var.tags,
    { Name = "${var.cluster_name}-node-memory-utilization" }
  )
}

// CloudWatch Alarm - Pod CPU Utilization
resource "aws_cloudwatch_metric_alarm" "pod_cpu" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.cluster_name}-pod-cpu-utilization"
  alarm_description   = "Alert when pod CPU utilization is very high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "pod_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = var.pod_cpu_threshold
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    ClusterName = var.cluster_name
  }

  tags = merge(
    var.tags,
    { Name = "${var.cluster_name}-pod-cpu-utilization" }
  )
}

// CloudWatch Dashboard for EKS monitoring
resource "aws_cloudwatch_dashboard" "eks" {
  count          = var.enable_container_insights ? 1 : 0
  dashboard_name = "${var.cluster_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["ContainerInsights", "node_cpu_utilization", { stat = "Average" }],
            [".", "node_memory_utilization", { stat = "Average" }],
            [".", "pod_cpu_utilization", { stat = "Average" }],
            [".", "pod_memory_utilization", { stat = "Average" }]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.id
          title  = "${var.cluster_name} - Resource Utilization"
        }
      },
      {
        type = "log"
        properties = {
          query   = "fields @timestamp, @message | filter @message like /ERROR/ | stats count() by bin(5m)"
          region  = data.aws_region.current.id
          title   = "${var.cluster_name} - Error Count"
        }
      }
    ]
  })
}

data "aws_region" "current" {}
