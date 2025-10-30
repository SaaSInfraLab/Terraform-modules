variable "azs" {
	description = "List of Availability Zones to create subnets in (one public + one private per AZ)"
	type        = list(string)
	default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_cidr" {
	description = "CIDR block for the VPC"
	type        = string
	default     = "10.0.0.0/16"
}

variable "nat_gateway_count" {
	description = "Number of NAT gateways to create (1..3). They will be placed in the first N public subnets"
	type        = number
	default     = 1
}

variable "name_prefix" {
	description = "Prefix used for resource naming"
	type        = string
	default     = "main"
}

variable "tags" {
	description = "Additional tags to apply to resources"
	type        = map(string)
	default     = {}
}

variable "allow_ssh" {
	description = "Whether to add an SSH ingress rule to node security group"
	type        = bool
	default     = false
}

variable "ssh_cidr" {
	description = "CIDR allowed to SSH to nodes when allow_ssh is true"
	type        = string
	default     = "0.0.0.0/0"
}

variable "enable_flow_logs" {
	description = "Enable VPC Flow Logs to CloudWatch Logs"
	type        = bool
	default     = false
}

variable "flow_log_traffic_type" {
	description = "Traffic type to capture for VPC Flow Logs (ACCEPT, REJECT, ALL)"
	type        = string
	default     = "ALL"
}

variable "flow_log_retention_in_days" {
	description = "Retention in days for the CloudWatch Log Group used by flow logs"
	type        = number
	default     = 90
}

variable "vpc_flow_logs_role_arn" {
  description = "Optional ARN of an existing IAM role to use for VPC Flow Logs. If empty, the module will create a role when flow logs are enabled."
  type        = string
  default     = ""
}

