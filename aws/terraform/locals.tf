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
      bastion_instance_type    = "t3.micro"
      jenkins_instance_type    = "t3.medium"
      eks_nodegroup_instance_types = ["t3.medium"]
      eks_node_scaling = {
        min_size     = 1
        max_size     = 2
        desired_size = 1
      }
      # Networking
      multi_az_nat             = false # Use a single NAT Gateway to save costs
      # Security
      bastion_ssh_cidr         = ["0.0.0.0/0"] # WARNING: Permissive for development.
      waf_enabled              = false # WAF can be disabled for early dev
    },
    qa = {
      # Resource Sizing
      bastion_instance_type    = "t3.micro"
      jenkins_instance_type    = "t3.large"
      eks_nodegroup_instance_types = ["m5.large"]
      eks_node_scaling = {
        min_size     = 2
        max_size     = 4
        desired_size = 2
      }
      # Networking
      multi_az_nat             = true
      # Security
      bastion_ssh_cidr         = var.qa_bastion_ssh_cidrs # Use a specific variable
      waf_enabled              = true
    },
    staging = {
      # Resource Sizing
      bastion_instance_type    = "t3.small"
      jenkins_instance_type    = "t3.xlarge"
      eks_nodegroup_instance_types = ["m5.xlarge"]
      eks_node_scaling = {
        min_size     = 2
        max_size     = 5
        desired_size = 3
      }
      # Networking
      multi_az_nat             = true
      # Security
      bastion_ssh_cidr         = var.staging_prod_bastion_ssh_cidrs # Stricter access
      waf_enabled              = true
    },
    prod = {
      # Resource Sizing
      bastion_instance_type    = "t3.small"
      jenkins_instance_type    = "t3.xlarge" # Jenkins might be a shared, highly available instance
      eks_nodegroup_instance_types = ["m5.2xlarge", "c5.2xlarge"]
      eks_node_scaling = {
        min_size     = 3
        max_size     = 10
        desired_size = 3
      }
      # Networking
      multi_az_nat             = true
      # Security
      bastion_ssh_cidr         = var.staging_prod_bastion_ssh_cidrs # Most restrictive access
      waf_enabled              = true
    }
  }

  # --- Selected Environment Configuration ---
  # This looks up the configuration map for the currently selected environment.
  # All other parts of the code should reference `local.env_config`
  env_config = local.env_configs[var.environment]
} 