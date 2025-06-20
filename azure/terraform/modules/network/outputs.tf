output "vnet_id" {
  description = "The ID of the virtual network."
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "The name of the virtual network."
  value       = azurerm_virtual_network.main.name
}

output "bastion_subnet_id" {
  description = "The ID of the bastion subnet."
  value       = azurerm_subnet.bastion.id
}

output "jenkins_subnet_id" {
  description = "The ID of the jenkins subnet."
  value       = azurerm_subnet.jenkins.id
}

output "app_gateway_subnet_id" {
  description = "The ID of the application gateway subnet."
  value       = azurerm_subnet.app_gateway.id
}

output "aks_node_pool_subnet_ids" {
  description = "A map of AKS node pool subnet IDs."
  value       = { for k, v in azurerm_subnet.aks_nodes : k => v.id }
} 