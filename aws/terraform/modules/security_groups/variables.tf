 # ------------------------------------------------------------------------------
# modules/security_groups/variables.tf
# ------------------------------------------------------------------------------
variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "bastion_ssh_cidr" {
  description = "CIDR block for SSH access to the bastion."
  type        = list(string)
}