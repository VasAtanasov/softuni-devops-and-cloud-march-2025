#!/bin/bash
set -euo pipefail

: "${INSTALL_LAZYDOCKER:=false}"
: "${INSTALL_DIVE:=false}"
: "${INSTALL_PORTAINER:=false}"
: "${INSTALL_PORTAINER_SWARM:=false}"
: "${INSTALL_DRY:=false}"
: "${INSTALL_TRIVY:=false}"
: "${INSTALL_HADOLINT:=false}"
: "${INSTALL_PUSHRM:=false}"

BIN_DIR="/usr/local/bin"
LOCAL_BIN="/home/vagrant/.local/bin"

log() {
  echo "$*"
}

require_cmds() {
  for cmd in "$@"; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "Error: Required command '$cmd' not found." >&2
      exit 1
    fi
  done
}

install_lazydocker() {
  log "Installing LazyDocker"
  local version
  version=$(curl -sL "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" |
    grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
  curl -sSLo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/download/v${version}/lazydocker_${version}_Linux_x86_64.tar.gz"
  tar xzvf lazydocker.tar.gz lazydocker
  install -Dm 755 lazydocker -t "$LOCAL_BIN"
  rm lazydocker lazydocker.tar.gz
}

install_dive() {
  log "Installing Dive"
  local version
  version=$(curl -sL "https://api.github.com/repos/wagoodman/dive/releases/latest" |
    grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
  curl -sSfOL "https://github.com/wagoodman/dive/releases/download/v${version}/dive_${version}_linux_amd64.deb"
  apt-get install -y "./dive_${version}_linux_amd64.deb"
  rm "./dive_${version}_linux_amd64.deb"
}

install_portainer() {
  log "Installing Portainer"
  docker volume create portainer_data
  docker run -d -p 9000:9000 -p 9443:9443 \
    --name portainer --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:lts
}

install_portainer_swarm() {
  log "Installing Portainer Swarm"
  curl -sSL https://downloads.portainer.io/ce-lts/portainer-agent-stack.yml -o portainer-agent-stack.yml
  docker stack deploy -c portainer-agent-stack.yml portainer
}

install_dry() {
  log "Installing Dry"
  curl -sSfL https://moncho.github.io/dry/dryup.sh | sh
  chmod 755 "$BIN_DIR/dry"
}

install_trivy() {
  log "Installing Trivy"
  curl -sSfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh |
    sh -s -- -b "$BIN_DIR" latest
}

install_hadolint() {
  log "Installing Hadolint"
  local version
  version=$(curl -sL "https://api.github.com/repos/hadolint/hadolint/releases/latest" |
    grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
  curl -sSfLo hadolint "https://github.com/hadolint/hadolint/releases/download/v${version}/hadolint-Linux-x86_64"
  chmod +x hadolint
  mv hadolint "$BIN_DIR/"
}

install_pushrm() {
  log "Installing Docker Push Readme"
  local version
  version=$(curl -sL "https://api.github.com/repos/christian-korneck/docker-pushrm/releases/latest" |
    grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
  curl -sSfLo docker-pushrm "https://github.com/christian-korneck/docker-pushrm/releases/download/v${version}/docker-pushrm_linux_amd64"
  chmod +x docker-pushrm
  mkdir -p "/usr/local/lib/docker/cli-plugins"
  mv docker-pushrm "/usr/local/lib/docker/cli-plugins/"
}

require_cmds curl tar grep sed

[[ "$INSTALL_LAZYDOCKER" == "true" ]] && install_lazydocker
[[ "$INSTALL_DIVE" == "true" ]] && install_dive
[[ "$INSTALL_PORTAINER" == "true" ]] && install_portainer
[[ "$INSTALL_PORTAINER_SWARM" == "true" ]] && install_portainer_swarm
[[ "$INSTALL_DRY" == "true" ]] && install_dry
[[ "$INSTALL_TRIVY" == "true" ]] && install_trivy
[[ "$INSTALL_HADOLINT" == "true" ]] && install_hadolint
[[ "$INSTALL_PUSHRM" == "true" ]] && install_pushrm