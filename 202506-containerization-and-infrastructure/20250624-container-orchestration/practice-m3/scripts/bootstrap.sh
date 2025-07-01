#!/bin/bash
set -e

# Add dynamic hosts if available
if [ -n "$HOST_ENTRIES" ]; then
  echo "* Adding dynamic hosts..."
  echo -e "$HOST_ENTRIES" >> /etc/hosts
else
  echo "WARN: HOST_ENTRIES not set. Skipping /etc/hosts update."
fi

echo "* Installing additional packages..."
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq jq yq tree git vim tmux

echo "* Disabling login message..."
: > /home/vagrant/.hushlogin

echo "* Setting greeting..."
GREETING_FILE="/etc/profile.d/greeting.sh"
[ -f "$GREETING_FILE" ] || cp /tmp/logo "$GREETING_FILE"

echo "* Docker Bash Completion..."
echo "source <(docker completion bash)" >> /home/vagrant/.bashrc