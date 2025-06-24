#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo "* Add hosts ..."
echo "192.168.99.200 docker.do1.lab docker" >> /etc/hosts

echo "* Install Additional Packages ..."
apt-get install -y jq tree git vim
