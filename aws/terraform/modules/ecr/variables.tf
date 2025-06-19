 # ------------------------------------------------------------------------------
# modules/ecr/variables.tf
# ------------------------------------------------------------------------------
variable "repository_names" {
  description = "A list of ECR repository names to create."
  type        = list(string)
}