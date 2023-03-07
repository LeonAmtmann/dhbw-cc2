resource "azurerm_network_interface" "dhbw-cc2-networkinterface" {
  name                = "dhbw-cc2-networkinterface"
  location            = azurerm_resource_group.dhbw-cc2-group.location
  resource_group_name = azurerm_resource_group.dhbw-cc2-group.name

  ip_configuration {
    name                          = "vm-ip-configuration"
    subnet_id                     = azurerm_virtual_network.dhbw-cc2-virtual-network.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
