# dhbw-cc2

## Local Requirements
- Azure CLI
- Terraform
- Ansible

## Running Step-by-Step

1. `az login`
2. `git clone https://github.com/LeonAmtmann/dhbw-cc2/`
3. `cd dhbw-cc2/terraform`
4. `terraform init`
5. `terraform apply`

## Notes:

- The `terraform apply` command will ask you to confirm the creation of the resources. Type `yes` and press enter.
- Ansible will ask to approve the fingerprint of the VMs. Type `yes` and press enter.
- Requesting an SSL certificate will only work if the domain at the top of the Ansible playbook is pointing to the public IP of the VM.
- Sometimes, DNS changes take a while to propagate. If you get an error message about the domain not being reachable when certbot tries requesting the certificate, wait a few minutes and try again.
- The Ansible script can be run manually by running `ansible-playbook -i ../inventory.ini ../compose_playbook.yml` in the `terraform` directory.
- You can check if the DNS change has propagated to your DNS provider of choice by running `dig <domain>`. You can also check if Cloudflare already has the most recent change on file by running `dig @1.1.1.1 <domain>`.
