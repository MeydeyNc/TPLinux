#!/bin/bash

# Màj
sudo dnf update -y


DIR="/var/web"
mkdir -p "$DIR"

# On ajoute les hosts
sudo sh -c "echo '10.5.1.111 rp1.tp5' >> /etc/hosts"
sudo sh -c "echo '10.5.1.211 db1.tp5' >> /etc/hosts"

# Conf pare feu
sudo firewall-cmd --add-port=22/tcp --permanent
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --reload

# Dockering
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io

# On lance Docker
sudo systemctl start docker
sudo systemctl enable docker

# On gère le user
USER="web1.docker"
sudo groupadd -r docker
sudo useradd -m -g docker "$USER"

# On crée le compose.sh
sudo tee "$DIR/compose.sh" > /dev/null <<EOF
#!/bin/bash
docker compose up -d
EOF
sudo chmod +x "$DIR/compose.sh"

# Du service après tout
sudo cat <<EOF | sudo tee /etc/systemd/system/serv.service > /dev/null
[Unit]
Description=Serv Start Service
After=network.target

[Service]
User=$USER
Group=docker
WorkingDirectory=$DIR
Restart=on-failure
ExecStart=$DIR/compose.sh

[Install]
WantedBy=multi-user.target
EOF

# Reboot et loading jespere yatoukimarche
sudo systemctl daemon-reload
sudo systemctl enable serv.service
sudo systemctl start serv.service

echo "Service configuré et démarré avec succès."

# Lancement de la suite
echo "Lancement du Docker compose"
sudo ./compose.sh
