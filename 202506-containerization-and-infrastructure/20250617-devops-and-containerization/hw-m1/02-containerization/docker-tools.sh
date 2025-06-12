#!/bin/bash

set -e

echo "# LazyDocker"
LAZYDOCKER_VERSION=$(curl -sL "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
curl -L -o lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
tar xzvf lazydocker.tar.gz lazydocker
install -Dm 755 lazydocker -t "/home/vagrant/.local/bin"
rm lazydocker lazydocker.tar.gz

echo "# Dive"
DIVE_VERSION=$(curl -sL "https://api.github.com/repos/wagoodman/dive/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
curl -fOL "https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.deb"
apt-get install -y ./dive_${DIVE_VERSION}_linux_amd64.deb
rm ./dive_${DIVE_VERSION}_linux_amd64.deb

echo "# Portrainer"
docker volume create portainer_data
docker run -d -p 9000:9000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:lts

echo "# Dry"
curl -sSf https://moncho.github.io/dry/dryup.sh | sh
chmod 755 /usr/local/bin/dry