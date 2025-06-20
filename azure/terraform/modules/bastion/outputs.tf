output "public_ip_address" {
  description = "The public IP address of the bastion host."
  value       = azurerm_public_ip.bastion.ip_address
} 