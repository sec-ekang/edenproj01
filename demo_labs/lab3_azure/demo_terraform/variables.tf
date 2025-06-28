variable "location" {
  description = "The Azure region to deploy the resources in."
  type        = string
  default     = "koreacentral"
}

variable "vnet_address_space" {
  description = "The address space for the Virtual Network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "public_subnet_1_prefix" {
  description = "The address prefix for Public Subnet 1 (AKS control plane)."
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_prefix" {
  description = "The address prefix for Public Subnet 2 (Jenkins)."
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_subnet_3_prefix" {
  description = "The address prefix for Public Subnet 3 (NAT Gateway)."
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_1_prefix" {
  description = "The address prefix for Private Subnet 1 (AKS nodes)."
  type        = string
  default     = "10.0.101.0/24"
}

variable "private_subnet_2_prefix" {
  description = "The address prefix for Private Subnet 2 (MySQL)."
  type        = string
  default     = "10.0.102.0/24"
}

variable "private_subnet_3_prefix" {
  description = "The address prefix for Private Subnet 3 (Build agents)."
  type        = string
  default     = "10.0.103.0/24"
}

variable "jenkins_vm_size" {
  description = "The size of the Jenkins VM."
  type        = string
  default     = "Standard_B2s"
}

variable "jenkins_admin_username" {
  description = "The admin username for the Jenkins VM."
  type        = string
  default     = "jenkinsadmin"
}

variable "jenkins_admin_ssh_key" {
  description = "The SSH public key for the Jenkins VM admin user."
  type        = string
  sensitive   = true
  # IMPORTANT: Replace this with your actual public SSH key
  default     = "ssh-rsa AAAA..."
}

variable "mysql_administrator_login" {
  description = "The administrator login for the MySQL server."
  type        = string
  default     = "mysqladmin"
}

variable "mysql_administrator_password" {
  description = "The administrator password for the MySQL server."
  type        = string
  sensitive   = true
  # IMPORTANT: Replace this with a strong password
  default     = "ThisIsAComplexPassword123!"
} 