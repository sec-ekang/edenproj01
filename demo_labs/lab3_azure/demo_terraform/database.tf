resource "azurerm_mysql_flexible_server" "main" {
  name                   = "mysql-${random_pet.rg_name.id}"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  delegated_subnet_id    = azurerm_subnet.private_db.id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql.id
  
  administrator_login    = var.mysql_administrator_login
  administrator_password = var.mysql_administrator_password

  sku_name   = "B_Standard_B1ms"
  version    = "8.0.21"
  storage_mb = 32768

  # Note: High availability and other production settings are omitted for brevity.
}

resource "azurerm_private_dns_zone" "mysql" {
  name                = "${random_pet.rg_name.id}.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "mysql-dns-vnet-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false
} 