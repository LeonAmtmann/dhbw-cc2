output "public_ip_address" {
  value = azurerm_network_interface.example.ip_configuration[0].public_ip_address
}