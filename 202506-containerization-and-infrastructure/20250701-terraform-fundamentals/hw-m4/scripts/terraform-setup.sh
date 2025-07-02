#!/bin/bash

if command -v terraform &>/dev/null; then
  echo "* Terraform is already installed. Skipping installation."
  exit 0
fi

echo "* Add Terraform Key ..."
wget -O - https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "* Add Terraform Repository ..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com \
  $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | \
  tee /etc/apt/sources.list.d/hashicorp.list

echo "* Install Terraform ..."
apt-get update
apt-get install terraform

echo "* Adding Terraform Command Competition"
echo "complete -C $(which terraform) terraform" >> /home/vagrant/.bashrc

echo "* Install TFLint"
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash


echo "* Install TFSpec"
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash