#!/bin/bash

# Zammad Installationsskript für Ubuntu

# Aktualisiere das System
sudo apt update
sudo apt upgrade -y

# Installiere benötigte Pakete
sudo apt install -y curl wget apt-transport-https vim

# Installiere PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Erstelle einen PostgreSQL-Benutzer für Zammad
sudo -u postgres psql -c "CREATE USER zammad WITH PASSWORD 'deinPasswort';"
sudo -u postgres psql -c "ALTER USER zammad WITH SUPERUSER;"

# Erstelle die Datenbank für Zammad
sudo -u postgres createdb -O zammad zammad_production

# Installiere Elasticsearch
sudo apt install -y openjdk-8-jre
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt update
sudo apt install -y elasticsearch

# Starte Elasticsearch
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch

# Installiere Zammad
wget -qO- https://ftp.zammad.com/zammad-latest.tar.gz | sudo tar xvz -C /opt
sudo ln -s /opt/zammad-*/ /opt/zammad

# Konfiguriere Zammad
sudo /opt/zammad/contrib/nginx/zammad-nginx.conf
sudo /opt/zammad/contrib/nginx/zammad-nginx-ssl.conf

# Starte Zammad-Dienste
sudo systemctl restart elasticsearch
sudo systemctl restart zammad

echo "Zammad wurde erfolgreich installiert. Du kannst auf die Webanwendung unter http://DEINE_SERVER_IP aufrufen."
