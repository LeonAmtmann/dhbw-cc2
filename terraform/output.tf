output "public_ip_address" {
  value = azurerm_network_interface.dhbw-cc2-networkinterface.ip_configuration[0].public_ip_address
}