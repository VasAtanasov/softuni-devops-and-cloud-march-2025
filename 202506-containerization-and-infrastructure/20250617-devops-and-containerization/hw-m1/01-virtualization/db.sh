#!/bin/bash

set -e # Exit on any error

echo "* Add hosts ..."
echo "192.168.89.100 web.do1.lab web" | tee -a /etc/hosts
echo "192.168.89.101 db.do1.lab db" | tee -a /etc/hosts

echo "* Update and install software ..."
apt-get update
apt-get upgrade -y
apt-get install -y mariadb-server git

echo "* Enable and start MariaDB ..."
systemctl enable mariadb
systemctl start mariadb

echo "Updating mariadb configs in /etc/mysql/mariadb.conf.d/50-server.cnf"
sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf
echo "Updated mariadb bind address in /etc/mysql/mariadb.conf.d/50-server.cnf to 0.0.0.0 to allow external connections."

echo "Restarting mariadb ..."
systemctl restart mariadb

echo "* Cloning backend ..."
cd ~
git clone https://github.com/shekeriev/bgapp

echo "* Create and load the database ..."
mysql <bgapp/db/db_setup.sql
