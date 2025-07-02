#!/bin/bash

sudo dnf install -y nginx

sudo systemctl start nginx
sudo systemctl enable nginx
