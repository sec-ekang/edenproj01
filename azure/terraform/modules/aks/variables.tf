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

variable "aks_cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
}

variable "aks_default_node_pool_count" {
  description = "The initial number of nodes for the default node pool."
  type        = number
  default     = 1
}

variable "aks_default_node_pool_vm_size" {
  description = "The VM size for the default node pool."
  type        = string
  default     = "Standard_DS2_v2"
}

variable "aks_default_node_pool_subnet_id" {
  description = "The subnet ID for the default AKS node pool."
  type        = string
}

variable "acr_id" {
  description = "The ID of the Azure Container Registry."
  type        = string
} 