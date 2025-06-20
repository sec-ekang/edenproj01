output "id" {
  description = "The ID of the Application Gateway."
  value       = azurerm_application_gateway.main.id
}

output "name" {
  description = "The name of the Application Gateway."
  value       = azurerm_application_gateway.main.name
}

output "public_ip_address" {
  description = "The public IP address of the Application Gateway."
  value       = azurerm_public_ip.app_gateway.ip_address
} 