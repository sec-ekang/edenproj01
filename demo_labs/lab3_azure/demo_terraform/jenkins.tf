# Jenkins VM Public IP
resource "azurerm_public_ip" "jenkins" {
  name                = "pip-jenkins"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Jenkins VM Network Interface
resource "azurerm_network_interface" "jenkins" {
  name                = "nic-jenkins"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.public_jenkins.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkins.id
  }
}

# Jenkins Virtual Machine
resource "azurerm_linux_virtual_machine" "jenkins" {
  name                  = "vm-jenkins"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = var.jenkins_vm_size
  admin_username        = var.jenkins_admin_username
  network_interface_ids = [azurerm_network_interface.jenkins.id]

  admin_ssh_key {
    username   = var.jenkins_admin_username
    public_key = var.jenkins_admin_ssh_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  
  identity {
    type = "SystemAssigned"
  }
}

# Grant Jenkins VM push access to ACR
resource "azurerm_role_assignment" "jenkins_acrpush" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_linux_virtual_machine.jenkins.identity[0].principal_id
} 