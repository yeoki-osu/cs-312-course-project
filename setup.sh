#!/bin/bash

cd automation/terraform
terraform init
terraform apply -auto-approve

PUBLIC_IP=$(terraform output -raw minecraft_server_ip)

wsl bash -c "
  cd ..
  cd ansible
  echo '[minecraft]' > inventory.ini
  echo '$PUBLIC_IP ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/minecraft-key.pem' >> inventory.ini
  ansible-playbook -i inventory.ini playbook.yml
"