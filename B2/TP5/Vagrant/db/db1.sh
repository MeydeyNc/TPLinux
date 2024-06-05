#!/bin/bash

# La Màj
sudo dnf update -y

# On bricole les hosts
HOSTS_FILE="/etc/hosts"
IP_RP1="10.5.1.111"
IP_WEB1="10.5.1.11"
DOMAIN_RP1="rp1.tp5"
DOMAIN_WEB1="web1.tp5" 

# Ajout de rp1 et web1
for domain in $DOMAIN_RP1 $DOMAIN_WEB1; do
    echo "${IP_RP1} ${domain}" | sudo tee -a "$HOSTS_FILE" >/dev/null
done

# Installation de MariaDB
sudo dnf install -y mariadb-server

# On lance et on voit
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Configuration de MariaDB pour écouter sur l'IP locale
BIND_ADDRESS= "$IP_WEB1" # Remplacez par l'adresse IP locale de votre serveur
CONFIG_FILE="/etc/mariadb/my.conf" # Correction ici pour utiliser le chemin correct
sudo mkdir -p $(dirname "$CONFIG_FILE")
echo "[mysqld]" | sudo tee "$CONFIG_FILE" > /dev/null
echo "bind-address = $BIND_ADDRESS" | sudo tee -a "$CONFIG_FILE" > /dev/null

# Redboot MariaDB
sudo systemctl restart mariadb

# CéLaDébé
DATABASE_NAME="app_nulle"
USERNAME="SQL"
PASSWORD="azerty"
INIT_SQL_FILE="/var/db/init.sql"

# C'est du SOUQUÉLÉ
mysql -u root -e "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;"
mysql -u root -e "CREATE USER IF NOT EXISTS '$USERNAME'@'web1.tp5.b2' IDENTIFIED BY '$PASSWORD';"
mysql -u root -e "GRANT ALL PRIVILEGES ON $DATABASE_NAME.* TO '$USERNAME'@'web1.tp5.b2';"
mysql -u root -e "FLUSH PRIVILEGES;"

# Importation de la base de données depuis init.sql
mysql -u root $DATABASE_NAME < $INIT_SQL_FILE

# Ouverture du port 3306 pour MariaDB
PORT_MARIADB="3306"
sudo firewall-cmd --add-port="$PORT_MARIADB"/tcp --permanent
sudo firewall-cmd --add-port=22/tcp --permanent

# Application des modifications de firewall
sudo firewall-cmd --reload

echo "MariaDB configuré et prêt à l'emploi."

# Non c'est pas l'IA arrêtez de demander.