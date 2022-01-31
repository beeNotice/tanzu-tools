##############################################
#                  Network                   #
##############################################
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.prefix}-${var.env}"
  resource_group_name = var.resource_group_name
  location            = var.location

  address_space = ["192.168.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "aks" {
  name                = "snet-${var.prefix}-aks-${var.env}"
  resource_group_name = var.resource_group_name

  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["192.168.1.0/24"]
}
