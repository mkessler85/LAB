#!/bin/bash

# Funktion für die Installation von Zammad
install_zammad() {
    echo "Installing Zammad..."

    # Zammad herunterladen und installieren
    curl -sSL https://packages.zammad.org/zammad/zammad-latest.tar.gz | tar xz -C /opt
    cd /opt/zammad

    # Konfiguration der Datenbank
    configure_database

    # Konfiguration von Elasticsearch
    configure_elasticsearch

    # Zammad Setup ausführen
    ./install.sh

    echo "Zammad installation completed."
}

# Funktion für die Konfiguration der Datenbank
configure_database() {
    echo "Configuring Zammad Database..."

    # Benutzereingabe für Datenbank-Details
    db_host=$(dialog --inputbox "Enter the Zammad database host:" 8 40 --output-fd 1)
    db_name=$(dialog --inputbox "Enter the Zammad database name:" 8 40 --output-fd 1)
    db_user=$(dialog --inputbox "Enter the Zammad database user:" 8 40 --output-fd 1)
    db_pass=$(dialog --passwordbox "Enter the Zammad database password:" 8 40 --output-fd 1)

    # PostgreSQL-Datenbank erstellen
    sudo -u postgres psql -c "CREATE DATABASE ${db_name} WITH ENCODING='UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0;"
    sudo -u postgres psql -c "CREATE USER ${db_user} WITH PASSWORD '${db_pass}';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${db_name} TO ${db_user};"

    # Konfigurationsdatei für Zammad aktualisieren
    sed -i "s/production:\n  adapter: sqlite3/production:\n  adapter: postgresql\n  database: ${db_name}\n  host: ${db_host}\n  username: ${db_user}\n  password: ${db_pass}/" /opt/zammad/config/database.yml

    echo "Zammad Database configuration completed."
}

# Funktion für die Konfiguration von Elasticsearch
configure_elasticsearch() {
    echo "Configuring Zammad Elasticsearch..."

    # Benutzereingabe für Elasticsearch-Details
    es_host=$(dialog --inputbox "Enter the Elasticsearch host:" 8 40 --output-fd 1)
    es_port=$(dialog --inputbox "Enter the Elasticsearch port (default is 9200):" 8 40 --output-fd 1)

    # Konfigurationsdatei für Zammad aktualisieren
    sed -i "s/\# elasticsearch:\n\#   hosts: localhost:9200/elasticsearch:\n  hosts: ${es_host}:${es_port}/" /opt/zammad/config/elasticsearch.yml

    echo "Zammad Elasticsearch configuration completed."
}

# Benutzereingabe für den Container-Namen
container_name=$(dialog --inputbox "Enter the Proxmox LXC container name:" 8 40 --output-fd 1)

# Benutzereingabe für die IP-Adresse des Containers
container_ip=$(dialog --inputbox "Enter the IP address for the container:" 8 40 --output-fd 1)

# Benutzereingabe für die Subnetzmaske
subnet_mask=$(dialog --inputbox "Enter the subnet mask for the container:" 8 40 --output-fd 1)

# Benutzereingabe für das Gateway
gateway=$(dialog --inputbox "Enter the gateway for the container:" 8 40 --output-fd 1)

# Proxmox LXC erstellen
echo "Creating Proxmox LXC container..."
pct create ${container_name} -osturnkey -arch amd64

# Netzwerkkonfiguration für den Container
pct set ${container_name} --ip ${container_ip} --net0 name=eth0,bridge=vmbr0,firewall=1,gw=${gateway},ip=${subnet_mask}

# Container starten
pct start ${container_name}

# Warten Sie, bis der Container gestartet ist
sleep 10

# Zammad installieren
install_zammad

echo "Proxmox LXC and Zammad installation completed."
