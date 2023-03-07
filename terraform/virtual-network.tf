resource "azurerm_virtual_network" "dhbw-cc2-virtual-network" {
  name                = "dhbw-cc2-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.dhbw-cc2-group.location
  resource_group_name = azurerm_resource_group.dhbw-cc2-group.name

  subnet {
    name           = "dhbw-cc2-subnet-1"
    address_prefix = "10.0.1.0/24"
  }
}
