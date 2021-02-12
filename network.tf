resource "azurerm_virtual_network" "resources" {
  name                = "${var.prefix}-network"
  location            = var.location
  resource_group_name = azurerm_resource_group.resources.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "resources_internal" {
  name                 = "${var.prefix}-internal"
  resource_group_name  = azurerm_resource_group.resources.name
  virtual_network_name = azurerm_virtual_network.resources.name
  address_prefix       = "10.0.0.0/24"
}

resource "azurerm_subnet" "resources_external" {
  name                 = "${var.prefix}-external"
  resource_group_name  = azurerm_resource_group.resources.name
  virtual_network_name = azurerm_virtual_network.resources.name
  address_prefix       = "10.0.2.0/24"
}
