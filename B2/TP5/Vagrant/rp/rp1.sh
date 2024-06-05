#!/bin/bash

# MAAAAJ
sudo dnf update -y

# Hosts
echo "10.5.1.11 web1.tp5" | sudo tee -a /etc/hosts >/dev/null
echo "10.5.1.12 web2.tp5" | sudo tee -a /etc/hosts >/dev/null
echo "10.5.1.13 web3.tp5" | sudo tee -a /etc/hosts >/dev/null
echo "10.5.1.211 db1.tp5" | sudo tee -a /etc/hosts >/dev/null

# C la conf
cp /var/rp/app_nulle.conf /etc/nginx/conf.d/app_nulle.conf

# N JINX
sudo dnf install nginx -y

# On lance
sudo systemctl start nginx
sudo systemctl enable nginx

#On installe Keepalived

sudo dnf install keepalived -y

# On configure

cp /var/rp/keepalived.conf /etc/keepalived/keepalived.conf


# On met le videur devant la boite
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --add-port=22/tcp --permanent
sudo firewall-cmd --reload

# On ouvre et on prie
echo "Nginx configuré et démarré avec succès."
