terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "cc2_rg" {
  name     = "cc2-resource-group"
  location = "East US"
}

resource "azurerm_cognitive_account" "text_analytics" {
  name                = "cc2-textanalyticsaccount"
  location            = azurerm_resource_group.cc2_rg.location
  resource_group_name = azurerm_resource_group.cc2_rg.name
  kind                = "TextAnalytics"
  sku_name            = "F0"

  tags = {
    Terraform = "true"
  }
}

output "text_analytics_endpoint" {
  sensitive = true
  value = azurerm_cognitive_account.text_analytics.endpoint
}

output "text_analytics_key1" {
  sensitive = true
  value = azurerm_cognitive_account.text_analytics.primary_access_key
}

resource "azurerm_virtual_network" "cc2_vnet" {
  name                = "cc2-virtual-network"
  location            = azurerm_resource_group.cc2_rg.location
  resource_group_name = azurerm_resource_group.cc2_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "cc2_subnet" {
  name                 = "cc2-subnet"
  resource_group_name  = azurerm_resource_group.cc2_rg.name
  virtual_network_name = azurerm_virtual_network.cc2_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "cc2_nic" {
  name                = "cc2-network-interface"
  location            = azurerm_resource_group.cc2_rg.location
  resource_group_name = azurerm_resource_group.cc2_rg.name

  ip_configuration {
    name                          = "cc2-ip-config"
    subnet_id                     = azurerm_subnet.cc2_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "cc2_vm" {
  name                  = "cc2-virtual-machine"
  location              = azurerm_resource_group.cc2_rg.location
  resource_group_name   = azurerm_resource_group.cc2_rg.name
  network_interface_ids = [azurerm_network_interface.cc2_nic.id]
  vm_size               = "Standard_B1s"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "cc2-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "cc2-vm"
    admin_username = "azureuser"
    admin_password = "P@ssw0rd123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "testing"
  }
}
