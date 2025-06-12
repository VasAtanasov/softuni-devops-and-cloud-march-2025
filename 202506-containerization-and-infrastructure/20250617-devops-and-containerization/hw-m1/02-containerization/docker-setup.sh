#!/bin/bash

set -e

# Before we can install Docker Engine, we need to uninstall any conflicting packages.
if command -v docker >/dev/null 2>&1; then
    echo "# Removing previouse versions of docker"
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
        apt-get remove -y $pkg
    done
    rm -rf /var/lib/docker
    rm -rf /var/lib/containerd
    rm /etc/apt/sources.list.d/docker.list
    rm /etc/apt/keyrings/docker.asc
else
    echo "# There is no docker installed"
fi
echo "* Add any prerequisites ..."
apt-get update
apt-get install -y ca-certificates curl

echo "# Add Docker's official GPG key"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "# Add the repository to Apt sources"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  bookworm stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

echo "# Installing Docker Engine"
apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "# Add vagrant user to docker group ..."
usermod -aG docker vagrant

echo "# Installing bash completion"
apt-get install -y bash-completion