# ------------------------------------------------------------------------------
# modules/vpc/variables.tf
# ------------------------------------------------------------------------------
variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "region" {
  description = "The AWS region."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones."
  type        = list(string)
}

variable "multi_az_nat" {
  description = "Whether to create a NAT Gateway in each Availability Zone."
  type        = bool
  default     = false
}
