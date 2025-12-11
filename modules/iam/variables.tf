variable "name_prefix" {
  description = "Prefix for all IAM role names"
  type        = string
  default     = "saaslab"
}

variable "cluster_name" {
  description = "EKS cluster name (used in role naming)"
  type        = string
  default     = "eks"
}

variable "tags" {
  description = "Additional tags to apply to IAM roles"
  type        = map(string)
  default     = {}
}

variable "create_eks_cluster_role" {
  description = "Whether to create the EKS cluster IAM role"
  type        = bool
  default     = true
}

variable "create_eks_node_role" {
  description = "Whether to create the EKS node IAM role"
  type        = bool
  default     = true
}

variable "create_vpc_flow_logs_role" {
  description = "Whether to create the VPC Flow Logs IAM role"
  type        = bool
  default     = true
}

variable "create_cloudwatch_agent_role" {
  description = "Whether to create the CloudWatch Agent IAM role"
  type        = bool
  default     = true
}

variable "create_eks_access_roles" {
  description = "Whether to create IAM roles for EKS cluster access (Admin, Developer, Viewer)"
  type        = bool
  default     = true
}

variable "eks_admin_trusted_principals" {
  description = "List of IAM principal ARNs that can assume the EKS Admin role"
  type        = list(string)
  default     = []
}

variable "eks_developer_trusted_principals" {
  description = "List of IAM principal ARNs that can assume the EKS Developer role"
  type        = list(string)
  default     = []
}

variable "eks_viewer_trusted_principals" {
  description = "List of IAM principal ARNs that can assume the EKS Viewer role"
  type        = list(string)
  default     = []
}

variable "aws_region" {
  description = "AWS region (used for assume role condition)"
  type        = string
  default     = ""
}

variable "create_secrets_manager_role" {
  description = "Whether to create the IAM role for Secrets Manager access via IRSA"
  type        = bool
  default     = false
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  type        = string
  default     = ""
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider"
  type        = string
  default     = ""
}

variable "secrets_manager_namespace" {
  description = "Kubernetes namespace where the service account for Secrets Manager access will be created"
  type        = string
  default     = "platform"
}

variable "secrets_manager_service_account" {
  description = "Name of the Kubernetes service account for Secrets Manager access"
  type        = string
  default     = "backend-sa"
}

variable "secrets_manager_secret_arns" {
  description = "List of ARNs of secrets in AWS Secrets Manager that the role can access"
  type        = list(string)
  default     = []
}

variable "secrets_manager_kms_key_arns" {
  description = "List of ARNs of KMS keys used to encrypt secrets (optional, defaults to AWS managed key)"
  type        = list(string)
  default     = []
}