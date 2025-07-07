#!/bin/bash

# Enable strict error handling
set -euo pipefail

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo"
    exit 1
fi

# Check for required commands
command -v curl >/dev/null 2>&1 || { echo "curl is required but not installed."; exit 1; }

# Check if Docker is already installed
if command -v docker &>/dev/null; then
    echo "* Docker is already installed. Skipping installation."
    exit 0
fi

echo "* Add any prerequisites ..."
apt-get update
apt-get install -y ca-certificates curl gnupg

echo "* Add Docker key ..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "* Add Docker repository ..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "* Install Docker ..."
apt-get update
apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Clean up apt cache to reduce image size
echo "* Cleaning up ..."
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "* Add vagrant user to docker group ..."
usermod -aG docker vagrant

# Verify Docker installation
echo "* Verifying Docker installation ..."
docker --version

echo "* Docker installation completed successfully!"
