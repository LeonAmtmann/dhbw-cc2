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