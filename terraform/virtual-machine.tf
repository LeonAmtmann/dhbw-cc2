resource "azurerm_virtual_machine" "example" {
  name                  = "your-virtual-machine-name"
  location              = azurerm_resource_group.dhbw-cc2-group.location
  resource_group_name   = azurerm_resource_group.dhbw-cc2-group.name
  network_interface_ids = [azurerm_network_interface.dhbw-cc2-networkinterface.id]

  vm_size  = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name = "dhbw-cc2-vm"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}