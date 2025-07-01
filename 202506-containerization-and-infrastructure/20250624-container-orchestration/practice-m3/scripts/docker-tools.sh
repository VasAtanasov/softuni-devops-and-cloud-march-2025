#!/bin/bash
set -euo pipefail

: "${INSTALL_LAZYDOCKER:=false}"
: "${INSTALL_DIVE:=false}"
: "${INSTALL_DRY:=false}"
: "${INSTALL_TRIVY:=false}"
: "${INSTALL_HADOLINT:=false}"
: "${INSTALL_PUSHRM:=false}"

BIN_DIR="/usr/local/bin"

log() {
  echo "* $*"
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
  if command -v lazydocker --version &>/dev/null; then
    log "LazyDocker is already installed"
    return
  fi
  log "Installing LazyDocker"
  local version
  version=$(curl -sL "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" |
    grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
  curl -sSLo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/download/v${version}/lazydocker_${version}_Linux_x86_64.tar.gz"
  tar xzvf lazydocker.tar.gz lazydocker
  install -Dm 755 lazydocker -t "$BIN_DIR"
  rm lazydocker lazydocker.tar.gz
}

install_dive() {
  if command -v dive &>/dev/null; then
    log "Dive is already installed"
    return
  fi
  log "Installing Dive"
  local version
  version=$(curl -sL "https://api.github.com/repos/wagoodman/dive/releases/latest" |
    grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
  curl -sSfOL "https://github.com/wagoodman/dive/releases/download/v${version}/dive_${version}_linux_amd64.deb"
  apt-get install -y "./dive_${version}_linux_amd64.deb"
  rm "./dive_${version}_linux_amd64.deb"
}

install_dry() {
  if command -v dry &>/dev/null; then
    log "Dry is already installed"
    return
  fi
  log "Installing Dry"
  curl -sSfL https://moncho.github.io/dry/dryup.sh | sh
  chmod 755 "$BIN_DIR/dry"
}

install_trivy() {
  if command -v trivy &>/dev/null; then
    log "Trivy is already installed"
    return
  fi
  log "Installing Trivy"
  curl -sSfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh |
    sh -s -- -b "$BIN_DIR" latest
}

install_hadolint() {
  if command -v hadolint &>/dev/null; then
    log "Hadolint is already installed"
    return
  fi
  log "Installing Hadolint"
  local version
  version=$(curl -sL "https://api.github.com/repos/hadolint/hadolint/releases/latest" |
    grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
  curl -sSfLo hadolint "https://github.com/hadolint/hadolint/releases/download/v${version}/hadolint-Linux-x86_64"
  chmod +x hadolint
  mv hadolint "$BIN_DIR/"
}

install_pushrm() {
  if [[ -x /usr/local/lib/docker/cli-plugins/docker-pushrm ]]; then
    log "Pushrm is already installed"
    return
  fi
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

if [[ "${INSTALL_LAZYDOCKER}" == "true" ]]; then
  install_lazydocker
fi

if [[ "${INSTALL_DIVE}" == "true" ]]; then
  install_dive
fi

if [[ "${INSTALL_DRY}" == "true" ]]; then
  install_dry
fi

if [[ "${INSTALL_TRIVY}" == "true" ]]; then
  install_trivy
fi

if [[ "${INSTALL_HADOLINT}" == "true" ]]; then
  install_hadolint
fi

if [[ "${INSTALL_PUSHRM}" == "true" ]]; then
  install_pushrm
fi