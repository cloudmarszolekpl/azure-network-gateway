provider "azurerm" {
  version = "2.1.0"
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "resources" {
  name     = "cd-az"
  location = var.location
}

