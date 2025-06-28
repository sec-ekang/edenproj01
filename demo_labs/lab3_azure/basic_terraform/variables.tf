variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
  type        = string
  default     = "jenkins-rg"
}

variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
  default     = "East US"
}

variable "vm_size" {
  description = "The size of the Virtual Machine."
  type        = string
  default     = "Standard_DS1_v2"
}

variable "admin_username" {
  description = "The username for the administrator account on the Virtual Machine."
  type        = string
  default     = "azureuser"
} 