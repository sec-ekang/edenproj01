resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.aks_cluster_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.aks_cluster_name}-${var.environment}"
  tags                = var.tags

  default_node_pool {
    name                = "default"
    vm_size             = var.aks_default_node_pool_vm_size
    vnet_subnet_id      = var.aks_default_node_pool_subnet_id
    min_count           = var.aks_default_node_pool_count
    max_count           = var.aks_default_node_pool_count + 2
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }

  role_based_access_control_enabled = true
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.aks_cluster_name}-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
} 