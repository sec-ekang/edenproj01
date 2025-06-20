output "id" {
  description = "The ID of the Azure Container Registry."
  value       = azurerm_container_registry.main.id
}

output "name" {
  description = "The name of the Azure Container Registry."
  value       = azurerm_container_registry.main.name
}

output "login_server" {
  description = "The login server of the Azure Container Registry."
  value       = azurerm_container_registry.main.login_server
} 