 # ------------------------------------------------------------------------------
# modules/iam/variables.tf
# ------------------------------------------------------------------------------
variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "aws_account_id" {
  description = "Current AWS Account ID."
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL for the EKS cluster."
  type        = string
  default     = ""
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for the EKS cluster."
  type        = string
  default     = ""
}

data "aws_region" "current" {}
