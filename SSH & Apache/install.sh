#!/bin/bash

set -e

echo "🔄 Updating system..."
sudo apt update -y

echo "📦 Installing OpenSSH Server..."
sudo apt install openssh-server -y

echo "📦 Installing Apache2..."
sudo apt install apache2 -y

echo "🚀 Starting services..."
sudo systemctl enable ssh
sudo systemctl start ssh

sudo systemctl enable apache2
sudo systemctl start apache2

echo "🔥 Allowing firewall ports..."
sudo ufw allow ssh
sudo ufw allow 'Apache Full'
sudo ufw enable

echo "🌐 Checking services..."
sudo systemctl status ssh --no-pager
sudo systemctl status apache2 --no-pager

echo "📡 Server IP:"
hostname -I

echo "✅ Setup complete!"
echo "👉 SSH: ssh username@server-ip"
echo "👉 Apache: http://server-ip"

echo "Change this file ac executable file before executing this command"
"sudo chmot +x (filename.sh)"
