# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-main"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# --- Subnets ---
resource "azurerm_subnet" "public_aks_control_plane" {
  name                 = "snet-public-aks-control-plane"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.public_subnet_1_prefix]
}

resource "azurerm_subnet" "public_jenkins" {
  name                 = "snet-public-jenkins"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.public_subnet_2_prefix]
  network_security_group_id = azurerm_network_security_group.jenkins.id
}

resource "azurerm_subnet" "public_nat" {
  name                 = "snet-public-nat"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.public_subnet_3_prefix]
}

resource "azurerm_subnet" "private_aks_nodes" {
  name                 = "snet-private-aks-nodes"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.private_subnet_1_prefix]
}

resource "azurerm_subnet" "private_db" {
  name                 = "snet-private-db"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.private_subnet_2_prefix]
  network_security_group_id = azurerm_network_security_group.database.id
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "Microsoft.DBforMySQL/flexibleServers"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "private_build_agents" {
  name                 = "snet-private-build-agents"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.private_subnet_3_prefix]
}

# --- Application Gateway ---
resource "azurerm_public_ip" "app_gateway" {
  name                = "pip-appgateway"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "main" {
  name                = "appgw-main"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }
  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.public_aks_control_plane.id # Dedicated subnet for App Gateway
  }
  frontend_port {
    name = "port_443"
    port = 443
  }
  frontend_ip_configuration {
    name                 = "appGatewayFrontendIp"
    public_ip_address_id = azurerm_public_ip.app_gateway.id
  }
  # Note: Backend pools, listeners, and rules are omitted for brevity.
  # SSL certificate from Key Vault would be configured here.
  # e.g., ssl_certificate { name = "cert-from-kv", key_vault_secret_id = ... }
  backend_address_pool {
    name = "backend-pool-temp"
  }
  http_listener {
    name                           = "listener-temp"
    frontend_ip_configuration_name = "appGatewayFrontendIp"
    frontend_port_name             = "port_443"
    protocol                       = "Https"
    ssl_certificate_name = "temp-cert" # Placeholder
  }
  request_routing_rule {
    name = "rule-temp"
    rule_type = "Basic"
    http_listener_name = "listener-temp"
    backend_address_pool_name = "backend-pool-temp"
    backend_http_settings_name = "http-settings-temp"
  }
  backend_http_settings {
    name = "http-settings-temp"
    cookie_based_affinity = "Disabled"
    port = 80
    protocol = "Http"
    request_timeout = 20
  }
  # Placeholder self-signed certificate for validation purposes
  ssl_certificate {
    name = "temp-cert"
    data = tls_self_signed_cert.appgw.cert_pem
    password = "Password123!"
  }
}

resource "tls_private_key" "appgw" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "appgw" {
  private_key_pem = tls_private_key.appgw.private_key_pem

  subject {
    common_name  = "temp.example.com"
    organization = "Temp Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}


# --- NAT Gateway ---
resource "azurerm_public_ip" "nat" {
  name                = "pip-nat"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "main" {
  name                    = "nat-main"
  location                = azurerm_resource_group.main.location
  resource_group_name     = azurerm_resource_group.main.name
  sku_name                = "Standard"
  public_ip_address_ids   = [azurerm_public_ip.nat.id]
}

# --- Network Security Groups ---
resource "azurerm_network_security_group" "jenkins" {
  name                = "nsg-jenkins"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTPS"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "database" {
  name                = "nsg-database"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "Allow-AKS-and-Jenkins"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefixes = [
      var.private_subnet_1_prefix, # AKS Nodes
      var.private_subnet_3_prefix, # Build Agents
      var.public_subnet_2_prefix   # Jenkins Master
    ]
    destination_address_prefix = "*"
  }
}

# --- Route Table for Private Subnets ---
resource "azurerm_route_table" "private" {
  name                          = "rt-private"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  disable_bgp_route_propagation = false

  route {
    name           = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "NatGateway"
  }
}

# --- Route Table Associations ---
resource "azurerm_subnet_route_table_association" "private_aks_nodes" {
  subnet_id      = azurerm_subnet.private_aks_nodes.id
  route_table_id = azurerm_route_table.private.id
}
resource "azurerm_subnet_route_table_association" "private_db" {
  subnet_id      = azurerm_subnet.private_db.id
  route_table_id = azurerm_route_table.private.id
}
resource "azurerm_subnet_route_table_association" "private_build_agents" {
  subnet_id      = azurerm_subnet.private_build_agents.id
  route_table_id = azurerm_route_table.private.id
} 