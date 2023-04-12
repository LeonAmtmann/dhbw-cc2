# Generate a random unique identifier for the SSH key
resource "random_pet" "key_id" {
  length = 2
}

# Create an RSA private key if the private key file does not already exist
resource "tls_private_key" "ssh_key" {
  count     = fileexists("${path.module}/ssh_key.pem") ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create a null resource to force the private key to be generated before the local_file resource
resource "null_resource" "depends_on_ssh_key" {
  count = length(tls_private_key.ssh_key)
  triggers = {
    key_id = tls_private_key.ssh_key[0].id
  }
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