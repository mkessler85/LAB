#!/bin/bash

# Überprüfen, ob das Skript mit dem gewünschten Namen (z.B. zammad.sh) aufgerufen wird
if [ "$0" != "./zammad.sh" ]; then
    echo "Bitte führen Sie das Skript mit dem Namen 'zammad.sh' aus."
    exit 1
fi

# Update the system
apt update
apt upgrade -y

# Install necessary dependencies
apt install -y curl wget apt-transport-https dirmngr

# Add the Zammad repository key
wget -qO- https://dl.packager.io/srv/zammad/zammad/key | apt-key add -

# Add the Zammad repository
echo "deb https://dl.packager.io/srv/zammad/zammad/stable/debian/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/zammad.list

# Update again to fetch the Zammad repository information
apt update

# Install Zammad
apt install -y zammad

# Start and enable Zammad services
systemctl start zammad
systemctl enable zammad

# Optionally, configure firewall rules if necessary
# Example: ufw allow 80/tcp
# Example: ufw allow 443/tcp

# Display information about the Zammad installation
echo "Zammad has been installed successfully."

# Optionally, display the login information or any additional setup steps
# Note: The following command is just an example and may not be accurate
echo "Login to Zammad at http://your-server-ip:8080"

# Optionally, you might need to restart the container for changes to take effect
# Example: reboot
