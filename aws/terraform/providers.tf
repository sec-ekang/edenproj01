 # ------------------------------------------------------------------------------
# providers.tf
#
# Specifies the required providers (in this case, AWS) and their versions.
# It also includes configuration for the provider, like the region.
# ------------------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}