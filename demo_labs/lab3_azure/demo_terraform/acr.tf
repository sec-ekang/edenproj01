resource "azurerm_container_registry" "main" {
  name                = "acr${random_pet.rg_name.id}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false # Use managed identity for auth
} 