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

resource "azurerm_public_ip" "cc2_public_ip" {
  name                = "cc2-public-ip"
  location            = azurerm_resource_group.cc2_rg.location
  resource_group_name = azurerm_resource_group.cc2_rg.name
  allocation_method   = "Static"
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
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.4"
    public_ip_address_id = azurerm_public_ip.cc2_public_ip.id
  }
}

resource "azurerm_network_security_group" "cc2_nsg" {
  name                = "cc2-nsg"
  location            = azurerm_resource_group.cc2_rg.location
  resource_group_name = azurerm_resource_group.cc2_rg.name
}

resource "azurerm_network_security_rule" "cc2_allow_http" {
  name                        = "cc2-allow-http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.cc2_nsg.name
  resource_group_name         = azurerm_resource_group.cc2_rg.name
}

resource "azurerm_network_security_rule" "cc2_allow_https" {
  name                        = "cc2-allow-https"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.cc2_nsg.name
  resource_group_name         = azurerm_resource_group.cc2_rg.name
}

resource "azurerm_network_security_rule" "cc2_allow_ssh" {
  name                        = "cc2-allow-ssh"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "94.16.106.239"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.cc2_nsg.name
  resource_group_name         = azurerm_resource_group.cc2_rg.name
}


resource "azurerm_network_interface_security_group_association" "cc2_nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.cc2_nic.id
  network_security_group_id = azurerm_network_security_group.cc2_nsg.id
}

resource "azurerm_linux_virtual_machine" "cc2_vm" {
  name                  = "cc2-virtual-machine"
  location              = azurerm_resource_group.cc2_rg.location
  resource_group_name   = azurerm_resource_group.cc2_rg.name
  network_interface_ids = [azurerm_network_interface.cc2_nic.id]
  size               = "Standard_F2s_v2"
  admin_username = "azureuser"

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching           = "ReadWrite"
  }

  admin_ssh_key {
    username = "azureuser"
    public_key = fileexists("${path.module}/ssh_key.pem") ? file("${path.module}/ssh_key.pub") : tls_private_key.ssh_key[0].public_key_openssh
  }

  tags = {
    environment = "testing"
  }
}