#!/bin/bash

echo "* Installing additional packages..."
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
  jq \
  yq \
  tree \
  git \
  vim \
  tmux \
  curl \
  wget \
  unzip \
  gnupg \
  w3m

echo "* Disabling login message..."
: > /home/vagrant/.hushlogin