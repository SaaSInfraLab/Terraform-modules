// CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/aws/vpc_flow_logs/${var.name_prefix}"
  retention_in_days = var.flow_log_retention_in_days

  tags = merge({ Name = "${var.name_prefix}-vpc-flow-logs" }, var.tags)
}

resource "aws_flow_log" "vpc" {
  count = var.enable_flow_logs ? 1 : 0

  vpc_id               = aws_vpc.main.id
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  iam_role_arn         = var.vpc_flow_logs_role_arn
  traffic_type         = var.flow_log_traffic_type

  tags = merge({ Name = "${var.name_prefix}-vpc-flow-log" }, var.tags)
}
