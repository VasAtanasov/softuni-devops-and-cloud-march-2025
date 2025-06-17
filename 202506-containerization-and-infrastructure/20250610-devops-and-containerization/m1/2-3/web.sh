#!/bin/bash

echo "* Add hosts ..."
echo "192.168.89.100 web.do1.lab web" >> /etc/hosts
echo "192.168.89.101 db.do1.lab db" >> /etc/hosts

echo "* Install Software ..."
dnf upgrade -y
dnf install -y httpd php php-mysqlnd git

echo "* Start HTTP ..."
systemctl enable httpd
systemctl start httpd

echo "* Firewall - open port 80 ..."
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --reload

echo "* Cloning frontend ..."
cd
sudo git clone https://github.com/shekeriev/bgapp

echo "Clean up /var/www/html/ ..."
sudo rm -rfv /var/www/html/*

echo "* Copy web site files to /var/www/html/ ..."
sudo cp bgapp/web/* /var/www/html
ls -alh /var/www/html

echo "* Allow HTTPD to make netork connections ..."
setsebool -P httpd_can_network_connect=1
