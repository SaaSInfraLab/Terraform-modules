variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE"
  type        = string
  default     = "MUTABLE"
  
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be either MUTABLE or IMMUTABLE"
  }
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "The encryption type to use for the repository. Valid values are AES256 or KMS"
  type        = string
  default     = "AES256"
  
  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type must be either AES256 or KMS"
  }
}

variable "kms_key_id" {
  description = "The KMS key to use when encryption_type is KMS. If not specified, uses the default AWS managed key for ECR"
  type        = string
  default     = null
}

variable "lifecycle_policy" {
  description = "The policy document for ECR lifecycle management. This is a JSON document. See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html"
  type        = string
  default     = null
}

variable "repository_policy" {
  description = "The policy document for ECR repository access. This is a JSON document."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

