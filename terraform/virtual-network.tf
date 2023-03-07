resource "azurerm_virtual_network" "example" {
  name                = "your-virtual-network-name"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  subnet {
    name           = "your-subnet-name"
    address_prefix = "10.0.1.0/24"
  }
}
