#!/bin/bash
set -e

check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo "Error: $1 is not installed or not in PATH"
        return 1
    fi
}

if command -v terraform &>/dev/null; then
    echo "* Terraform is already installed. Skipping installation."
    exit 0
fi

echo "* Installing prerequisites..."
apt-get update
apt-get install -y wget curl gpg lsb-release

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
apt-get install -y terraform

if ! terraform version; then
    echo "Error: Terraform installation failed"
    exit 1
fi

echo "* Adding Terraform Command Completion..."
echo "complete -C $(which terraform) terraform" >> /home/vagrant/.bashrc

echo "* Install TFLint..."
TFLINT_VERSION="v0.50.0"
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | \
    TFLINT_VERSION=$TFLINT_VERSION bash

if ! tflint --version; then
    echo "Error: TFLint installation failed"
    exit 1
fi

echo "* Install TFSec..."
TFSEC_VERSION="v1.28.4"
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | \
    TFSEC_VERSION=$TFSEC_VERSION bash

if ! tfsec --version; then
    echo "Error: TFSec installation failed"
    exit 1
fi

echo "* Cleaning up..."
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "* All installations completed successfully!"

echo "* Verifying all installations..."
for cmd in terraform tflint tfsec; do
    if ! check_command $cmd; then
        echo "Final verification failed for $cmd"
        exit 1
    fi
done

echo "* All tools verified and ready to use!"
