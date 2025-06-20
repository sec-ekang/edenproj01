################################################################################
# Root Module - locals.tf
#
# This file centralizes all environment-specific configurations.
# It defines maps for various settings, and the `env_config` local
# selects the correct map based on the `var.environment` input variable.
################################################################################

locals {
  # --- Configuration Maps for Each Environment ---
  env_configs = {
    dev = {
      # Resource Sizing
      bastion_vm_size    = "Standard_B1s"  # Smallest, burstable
      jenkins_vm_size    = "Standard_B2s"  # Burstable for build spikes
      aks_node_count     = 1
      aks_vm_size        = "Standard_DS2_v2"
      acr_sku            = "Basic"
      # Networking
      multi_az_nat       = false # Use a single NAT Gateway to save costs
      # Security
      bastion_ssh_cidr   = ["0.0.0.0/0"] # WARNING: Permissive for development.
      app_gateway_enabled = false
    },
    qa = {
      # Resource Sizing
      bastion_vm_size    = "Standard_B1s"
      jenkins_vm_size    = "Standard_D2as_v4" # General purpose for more stable performance
      aks_node_count     = 2
      aks_vm_size        = "Standard_DS3_v2"
      acr_sku            = "Standard"
      # Networking
      multi_az_nat       = true
      # Security
      bastion_ssh_cidr   = var.qa_bastion_ssh_cidrs # Use a specific variable
      app_gateway_enabled = true
    },
    staging = {
      # Resource Sizing
      bastion_vm_size    = "Standard_B2s"
      jenkins_vm_size    = "Standard_D4as_v4"
      aks_node_count     = 3
      aks_vm_size        = "Standard_DS4_v2"
      acr_sku            = "Premium"
      # Networking
      multi_az_nat       = true
      # Security
      bastion_ssh_cidr   = var.staging_prod_bastion_ssh_cidrs # Stricter access
      app_gateway_enabled = true
    },
    prod = {
      # Resource Sizing
      bastion_vm_size    = "Standard_B2s"
      jenkins_vm_size    = "Standard_D4as_v4"
      aks_node_count     = 3 # Start with 3, but with autoscaling enabled
      aks_vm_size        = "Standard_DS4_v2"
      acr_sku            = "Premium" # Premium for geo-replication and higher limits
      # Networking
      multi_az_nat       = true
      # Security
      bastion_ssh_cidr   = var.staging_prod_bastion_ssh_cidrs # Most restrictive access
      app_gateway_enabled = true
    }
  }

  # --- Selected Environment Configuration ---
  # This looks up the configuration map for the currently selected environment.
  # All other parts of the code should reference `local.env_config`
  env_config = local.env_configs[var.environment]
} 