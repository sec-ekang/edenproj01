output "public_ip_address" {
  description = "The public IP address of the jenkins server."
  value       = azurerm_public_ip.jenkins.ip_address
} 