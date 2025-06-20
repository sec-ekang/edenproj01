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

variable "vnet_name" {
  description = "The name of the virtual network."
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the virtual network."
  type        = list(string)
}

variable "bastion_subnet_address_prefixes" {
  description = "The address prefixes for the bastion subnet."
  type        = list(string)
}

variable "jenkins_subnet_address_prefixes" {
  description = "The address prefixes for the jenkins subnet."
  type        = list(string)
}

variable "nat_gateway_subnet_address_prefixes" {
  description = "The address prefixes for the nat gateway subnet."
  type        = list(string)
}

variable "app_gateway_subnet_address_prefixes" {
  description = "The address prefixes for the application gateway subnet."
  type        = list(string)
}

variable "aks_node_pools_subnets" {
  description = "A map of AKS node pool subnets."
  type        = map(string)
} 