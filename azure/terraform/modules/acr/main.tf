resource "azurerm_container_registry" "main" {
  name                = "${var.acr_name}${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = false
  tags                = var.tags
} 