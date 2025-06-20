resource "azurerm_resource_group" "main" {
  name     = "${var.resource_group_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}

module "network" {
  source                = "./modules/network"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  environment           = var.environment
  tags                  = var.tags
  vnet_name             = var.vnet_name
  vnet_address_space    = var.vnet_address_space
  bastion_subnet_address_prefixes = var.bastion_subnet_address_prefixes
  jenkins_subnet_address_prefixes = var.jenkins_subnet_address_prefixes
  nat_gateway_subnet_address_prefixes = var.nat_gateway_subnet_address_prefixes
  app_gateway_subnet_address_prefixes = var.app_gateway_subnet_address_prefixes
  aks_node_pools_subnets = var.aks_node_pools_subnets
}

module "nsg" {
  source                        = "./modules/nsg"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  environment                   = var.environment
  tags                          = var.tags
  approved_ssh_ips              = local.env_config.bastion_ssh_cidr
  bastion_subnet_id             = module.network.bastion_subnet_id
  jenkins_subnet_id             = module.network.jenkins_subnet_id
  aks_node_pool_subnet_ids      = module.network.aks_node_pool_subnet_ids
  bastion_subnet_address_prefix = var.bastion_subnet_address_prefixes[0]
  jenkins_subnet_address_prefix = var.jenkins_subnet_address_prefixes[0]
}

module "acr" {
  source              = "./modules/acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  tags                = var.tags
  acr_name            = var.acr_name
  acr_sku             = local.env_config.acr_sku
}

module "aks" {
  source                          = "./modules/aks"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  environment                     = var.environment
  tags                            = var.tags
  aks_cluster_name                = var.aks_cluster_name
  aks_default_node_pool_subnet_id = module.network.aks_node_pool_subnet_ids["aks-nodepool-1"]
  acr_id                          = module.acr.id
  aks_default_node_pool_vm_size   = local.env_config.aks_vm_size
  aks_default_node_pool_count     = local.env_config.aks_node_count
}

module "app_gateway" {
  count                 = local.env_config.app_gateway_enabled ? 1 : 0
  source                = "./modules/app_gateway"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  environment           = var.environment
  tags                  = var.tags
  app_gateway_subnet_id = module.network.app_gateway_subnet_id
}

module "bastion" {
  source              = "./modules/bastion"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  tags                = var.tags
  bastion_subnet_id   = module.network.bastion_subnet_id
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  vm_size             = local.env_config.bastion_vm_size
}

module "jenkins" {
  source              = "./modules/jenkins"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  tags                = var.tags
  jenkins_subnet_id   = module.network.jenkins_subnet_id
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  vm_size             = local.env_config.jenkins_vm_size
} 