resource "azurerm_virtual_network" "main" {
  name                = "${var.vnet_name}-${var.environment}"
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "bastion" {
  name                 = "bastion-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.bastion_subnet_address_prefixes
}

resource "azurerm_subnet" "jenkins" {
  name                 = "jenkins-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.jenkins_subnet_address_prefixes
}

resource "azurerm_subnet" "nat_gateway" {
  name                 = "nat-gateway-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.nat_gateway_subnet_address_prefixes
}

resource "azurerm_subnet" "app_gateway" {
  name                 = "app-gateway-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.app_gateway_subnet_address_prefixes
}

resource "azurerm_subnet" "aks_nodes" {
  for_each             = var.aks_node_pools_subnets
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value]
}

resource "azurerm_public_ip" "nat_gateway" {
  name                = "nat-gateway-pip-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "main" {
  name                = "nat-gateway-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
  idle_timeout_in_minutes = 10
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat_gateway.id
}

resource "azurerm_subnet_nat_gateway_association" "aks" {
  for_each       = azurerm_subnet.aks_nodes
  subnet_id      = each.value.id
  nat_gateway_id = azurerm_nat_gateway.main.id
} 