variable "location" {
  description = "The Azure region to deploy the resources."
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "The deployment environment (e.g., dev, qa, staging, prod)."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "vnet_name" {
  description = "The name of the virtual network."
  type        = string
  default     = "sock-shop-vnet"
}

variable "vnet_address_space" {
  description = "The address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "bastion_subnet_address_prefixes" {
  description = "The address prefixes for the bastion subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "jenkins_subnet_address_prefixes" {
  description = "The address prefixes for the jenkins subnet."
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "nat_gateway_subnet_address_prefixes" {
  description = "The address prefixes for the nat gateway subnet."
  type        = list(string)
  default     = ["10.0.3.0/24"]
}

variable "app_gateway_subnet_address_prefixes" {
  description = "The address prefixes for the application gateway subnet."
  type        = list(string)
  default     = ["10.0.6.0/24"]
}

variable "aks_node_pools_subnets" {
  description = "A map of AKS node pool subnets."
  type        = map(string)
  default = {
    "aks-nodepool-1" = "10.0.4.0/24"
    "aks-nodepool-2" = "10.0.5.0/24"
  }
}

variable "qa_bastion_ssh_cidrs" {
  description = "CIDR block for Bastion host SSH access in the QA environment."
  type        = list(string)
  default     = []
}

variable "staging_prod_bastion_ssh_cidrs" {
  description = "CIDR block for Bastion host SSH access in Staging and Prod."
  type        = list(string)
  default     = []
}

variable "approved_ssh_ips" {
  description = "A list of approved IP addresses for SSH access to the bastion."
  type        = list(string)
}

variable "acr_name" {
  description = "The name of the Azure Container Registry."
  type        = string
  default     = "sockshopacr"
}

variable "acr_sku" {
  description = "The SKU for the Azure Container Registry."
  type        = string
  default     = "Standard"
}

variable "aks_cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
  default     = "sock-shop-aks"
}

variable "admin_username" {
  description = "The admin username for the VMs."
  type        = string
  default     = "adminuser"
}

variable "admin_password" {
  description = "The admin password for the VMs."
  type        = string
  sensitive   = true
} 