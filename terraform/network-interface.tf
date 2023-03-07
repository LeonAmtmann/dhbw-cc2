resource "azurerm_network_interface" "example" {
  name                = "your-network-interface-name"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "your-ip-configuration-name"
    subnet_id                     = azurerm_virtual_network.example.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
