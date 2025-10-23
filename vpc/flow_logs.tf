// CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/aws/vpc_flow_logs/${var.name_prefix}"
  retention_in_days = var.flow_log_retention_in_days

  tags = merge({ Name = "${var.name_prefix}-vpc-flow-logs" }, var.tags)
}

// IAM role for VPC Flow Logs to publish to CloudWatch Logs
resource "aws_iam_role" "vpc_flow_logs_role" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${var.name_prefix}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      }
    ]
  })

  tags = merge({ Name = "${var.name_prefix}-vpc-flow-logs-role" }, var.tags)
}

resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${var.name_prefix}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs_role[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"
      }
    ]
  })
}

// VPC Flow Log sending to CloudWatch Logs
resource "aws_flow_log" "vpc" {
  count = var.enable_flow_logs ? 1 : 0

  vpc_id               = aws_vpc.main.id
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  iam_role_arn         = aws_iam_role.vpc_flow_logs_role[0].arn
  traffic_type         = var.flow_log_traffic_type

  tags = merge({ Name = "${var.name_prefix}-vpc-flow-log" }, var.tags)
}
