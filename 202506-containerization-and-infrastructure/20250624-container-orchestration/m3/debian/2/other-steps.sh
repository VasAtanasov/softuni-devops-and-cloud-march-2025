#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo "* Add hosts ..."
echo "192.168.99.201 docker1.do1.lab docker1" >> /etc/hosts
echo "192.168.99.202 docker2.do1.lab docker2" >> /etc/hosts
echo "192.168.99.203 docker3.do1.lab docker3" >> /etc/hosts

echo "* Install Additional Packages ..."
apt-get install -y jq tree git vim