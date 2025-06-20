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

variable "approved_ssh_ips" {
  description = "A list of approved IP addresses for SSH access to the bastion."
  type        = list(string)
}

variable "bastion_subnet_id" {
  description = "The ID of the bastion subnet."
  type        = string
}

variable "jenkins_subnet_id" {
  description = "The ID of the jenkins subnet."
  type        = string
}

variable "aks_node_pool_subnet_ids" {
  description = "A map of AKS node pool subnet IDs."
  type        = map(string)
}

variable "bastion_subnet_address_prefix" {
  description = "The address prefix for the bastion subnet."
  type        = string
}

variable "jenkins_subnet_address_prefix" {
  description = "The address prefix for the jenkins subnet."
  type        = string
} 