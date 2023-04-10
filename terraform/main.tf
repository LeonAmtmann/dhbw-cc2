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

# Add the Azure Cosmos DB account configuration
resource "azurerm_cosmosdb_account" "cc2_cosmosdb" {
  name                = "cc2-cosmosdb"
  location            = azurerm_resource_group.cc2_rg.location
  resource_group_name = azurerm_resource_group.cc2_rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  geo_location {
    location          = azurerm_resource_group.cc2_rg.location
    failover_priority = 0
  }
}

# Add outputs for Cosmos DB properties
output "cosmos_db_id" {
  value = azurerm_cosmosdb_account.cc2_cosmosdb.id
}

output "cosmos_db_endpoint" {
  value = azurerm_cosmosdb_account.cc2_cosmosdb.endpoint
}

output "cosmos_db_endpoints_read" {
  value = azurerm_cosmosdb_account.cc2_cosmosdb.read_endpoints
}

output "cosmos_db_endpoints_write" {
  value = azurerm_cosmosdb_account.cc2_cosmosdb.write_endpoints
}

output "cosmos_db_primary_key" {
  sensitive = true
  value     = azurerm_cosmosdb_account.cc2_cosmosdb.primary_key
}

output "cosmos_db_secondary_key" {
  sensitive = true
  value     = azurerm_cosmosdb_account.cc2_cosmosdb.secondary_key
}

resource "azurerm_public_ip" "cc2_public_ip" {
  name                = "cc2-public-ip"
  location            = azurerm_resource_group.cc2_rg.location
  resource_group_name = azurerm_resource_group.cc2_rg.name
  allocation_method   = "Static"
}

resource "azurerm_cognitive_account" "cog_text_analytics" {
  name                = "cc2-cog-text-analytics"
  location            = azurerm_resource_group.cc2_rg.location
  resource_group_name = azurerm_resource_group.cc2_rg.name
  kind                = "CognitiveServices"
  sku_name            = "S0"
}

output "text_analytics_endpoint" {
  sensitive = true
  value = azurerm_cognitive_account.cog_text_analytics.endpoint
}

output "text_analytics_key1" {
  sensitive = true
  value = azurerm_cognitive_account.cog_text_analytics.primary_access_key
}

output "public_ip_address" {
  value = azurerm_public_ip.cc2_public_ip.ip_address
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
  admin_password = "P@ssw0rd123!"

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
    public_key = file("~/.ssh/keys/macbook.pub")
  }

  tags = {
    environment = "testing"
  }
}