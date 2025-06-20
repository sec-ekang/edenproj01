variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The Azure region to deploy the resources."
  type        = string
}

variable "environment" {
  description = "The deployment environment."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
}

variable "bastion_subnet_id" {
  description = "The ID of the subnet for the bastion host."
  type        = string
}

variable "admin_username" {
  description = "The admin username for the bastion VM."
  type        = string
}

variable "admin_password" {
  description = "The admin password for the bastion VM."
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "The size of the bastion VM."
  type        = string
  default     = "Standard_B1s"
} 