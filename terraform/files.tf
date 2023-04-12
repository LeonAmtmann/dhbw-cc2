resource "local_file" "env_file" {
  content = <<EOF
LANGUAGE_API_KEY=${azurerm_cognitive_account.cog_text_analytics.primary_access_key}
ENDPOINT=${azurerm_cognitive_account.cog_text_analytics.endpoint}
COSMOS_STRING="${azurerm_cosmosdb_account.cc2_cosmosdb.connection_strings[0]}"
EOF
  filename = "${path.module}/.env"
}

resource "local_file" "inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    vm_ip       = azurerm_public_ip.cc2_public_ip.ip_address
    ansible_user = "azureuser"
    ssh_key_path = "./terraform/ssh_key.pem"
  })
  filename = "${path.module}/../inventory.ini"
}

# Save the generated private key to a local file with appropriate permissions
resource "local_file" "private_key" {
  depends_on      = [null_resource.depends_on_ssh_key]
  content         = fileexists("${path.module}/ssh_key.pem") ? file("${path.module}/ssh_key.pem") : tls_private_key.ssh_key[0].private_key_pem
  filename        = "${path.module}/ssh_key.pem"
  file_permission = "0600"

  # Save the corresponding public key to a local file using a local-exec provisioner
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.ssh_key[0].public_key_openssh}\" > ${path.module}/ssh_key.pub"
  }
}