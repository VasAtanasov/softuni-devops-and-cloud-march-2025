#!/bin/bash

set -euo pipefail

if [[ -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
  echo "* AWS credentials not found in environment. Skipping AWS CLI installation."
  exit 0
fi

if command -v aws >/dev/null 2>&1 && aws --version | grep -q 'aws-cli/2'; then
  echo "* AWS CLI v2 is already installed. Skipping installation."
else
  echo "Installing AWS CLI v2..."
  curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -q awscliv2.zip
  sudo ./aws/install
  rm -rf aws awscliv2.zip
fi

if [[ ! -f "/home/vagrant/.aws/config" || ! -f "/home/vagrant/.aws/credentials" ]]; then
  echo "* Configuring AWS CLI..."
  mkdir -p "/home/vagrant/.aws"

  aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
  aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"

  if [[ -n "${AWS_DEFAULT_REGION:-}" ]]; then
    aws configure set region "$AWS_DEFAULT_REGION"
  else
    aws configure set region "us-east-1"
  fi

  if [[ -n "${AWS_OUTPUT_FORMAT:-}" ]]; then
    aws configure set output "$AWS_OUTPUT_FORMAT"
  else
    aws configure set output "json"
  fi

  aws configure list
else
  echo "* AWS CLI is already configured. Skipping configuration."
fi

if ! grep -q "complete -C $(which aws_completer) aws" /home/vagrant/.bashrc; then
  echo '* Enabling AWS CLI autocomplete...'
  echo "complete -C $(which aws_completer) aws" >> /home/vagrant/.bashrc
else
  echo "* Autocomplete already enabled."
fi

echo "* AWS CLI configured successfully."