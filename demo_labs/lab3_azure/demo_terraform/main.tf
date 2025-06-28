terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_pet" "rg_name" {
  prefix = "lab4"
}

resource "azurerm_resource_group" "main" {
  name     = random_pet.rg_name.id
  location = var.location
} 