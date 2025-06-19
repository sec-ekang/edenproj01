# ------------------------------------------------------------------------------
# modules/eks/variables.tf
# ------------------------------------------------------------------------------
variable "project_name" {
  type = string
}
variable "cluster_name" {
  type = string
}
variable "cluster_version" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "eks_cluster_role_arn" {
  type = string
}
variable "eks_nodegroup_role_arn" {
  type = string
}
variable "nodegroup_instance_types" {
  type = list(string)
}
variable "eks_node_sg_id" {
  type = string
}

variable "eks_node_scaling_min_size" {
  description = "Minimum number of nodes in the EKS node group."
  type        = number
  default     = 1
}

variable "eks_node_scaling_max_size" {
  description = "Maximum number of nodes in the EKS node group."
  type        = number
  default     = 3
}

variable "eks_node_scaling_desired_size" {
  description = "Desired number of nodes in the EKS node group."
  type        = number
  default     = 2
}