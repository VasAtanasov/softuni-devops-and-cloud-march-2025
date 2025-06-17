#!/bin/bash

set -e # Exit on error

echo "* Add hosts ..."
echo "192.168.89.100 web.do1.lab web" | tee -a /etc/hosts
echo "192.168.89.101 db.do1.lab db" | tee -a /etc/hosts

echo "* Update and install software ..."
apt-get update
apt-get upgrade -y
apt-get install -y apache2 php php-mysql git

echo "* Enable and start Apache ..."
systemctl enable apache2
systemctl start apache2

echo "* Cloning frontend ..."
cd ~
git clone https://github.com/shekeriev/bgapp

echo "* Clean up /var/www/html/ ..."
rm -rfv /var/www/html/*

echo "* Copy web site files to /var/www/html/ ..."
cp -r bgapp/web/* /var/www/html
ls -alh /var/www/html
