resource "azurerm_virtual_machine" "example" {
  name                  = "your-virtual-machine-name"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]

  vm_size  = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "your-os-disk-name"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name = "your-computer-name"
    admin_username = "your-admin-username"
    admin_password = "your-admin-password"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}