// start gateway definition
resource "azurerm_subnet" "resources_gateway" {
  name                 = "GatewaySubnet"   // must be this name
  resource_group_name  = azurerm_resource_group.resources.name
  virtual_network_name = azurerm_virtual_network.resources.name
  address_prefix       = "10.0.1.0/24"
}


resource "azurerm_public_ip" "public_ip_1" {
  name                = "${var.prefix}-virtual_network_gateway_public_ip_1"
  location            = azurerm_resource_group.resources.location
  resource_group_name = azurerm_resource_group.resources.name

  # Public IP needs to be dynamic for the Virtual Network Gateway
  # Keep in mind that the IP address will be "dynamically generated" after
  # being attached to the Virtual Network Gateway below
  allocation_method = "Dynamic"
}

resource "azurerm_public_ip" "public_ip_2" {
  name                = "${var.prefix}-virtual_network_gateway_public_ip_2"
  location            = azurerm_resource_group.resources.location
  resource_group_name = azurerm_resource_group.resources.name

  # Public IP needs to be dynamic for the Virtual Network Gateway
  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "virtual_network_gateway" {
  name                = "${var.prefix}-virtual_network_gateway"
  location            = azurerm_resource_group.resources.location
  resource_group_name = azurerm_resource_group.resources.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  # Configuration for high availability
  active_active = true
  # This might me expensive, check the prices  
  sku           = "VpnGw1"

  # Configuring the two previously created public IP Addresses
  ip_configuration {
    name                          = azurerm_public_ip.public_ip_1.name
    public_ip_address_id          = azurerm_public_ip.public_ip_1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.resources_gateway.id
  }

  ip_configuration {
    name                          = azurerm_public_ip.public_ip_2.name
    public_ip_address_id          = azurerm_public_ip.public_ip_2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.resources_gateway.id
  } 
}

resource "azurerm_local_network_gateway" "local_network_gateway_1_tunnel1" {
  name                = "local_network_gateway_1_tunnel1"
  location            = azurerm_resource_group.resources.location
  resource_group_name = azurerm_resource_group.resources.name

  # local ip address
  gateway_address = "${var.destination_ip_address}"
  address_space = [
    # local adress range 
    "${var.destination_ip_range}"
  ]
}

resource "azurerm_virtual_network_gateway_connection" "virtual_network_gateway_connection_1_tunnel1" {
  name                = "virtual_network_gateway_connection_1_tunnel1"
  location            = azurerm_resource_group.resources.location
  resource_group_name = azurerm_resource_group.resources.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.virtual_network_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.local_network_gateway_1_tunnel1.id

  # local shared key 
  shared_key = "${var.local_shared_key}"
}

output "azurerm_public_ip_1" {
  value = azurerm_public_ip.public_ip_1.ip_address
}

output "azurerm_public_ip_2" {
  value = azurerm_public_ip.public_ip_2.ip_address
} 