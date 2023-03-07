provider "azurerm" {
  features {
    virtual_machine {
      delete_os_disk_on_deletion = false
    }
    network {
      relaxed_locking = true
    }
  }
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}
