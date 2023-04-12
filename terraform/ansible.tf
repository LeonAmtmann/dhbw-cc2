resource "null_resource" "run_ansible" {
  depends_on = [local_file.inventory, local_file.env_file]

  provisioner "local-exec" {
    command = "ansible-playbook -v -i ${path.module}/../inventory.ini ${path.module}/../compose_playbook.yml"
  }
}