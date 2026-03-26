#!/bin/bash
# configure-server.sh
# Server configuration script for NotesApp.
# Downloaded and executed by EC2 user data on first boot.

set -e

echo "Updating system packages..."
dnf update -y

echo "Installing required packages..."
dnf install -y git nodejs

echo "Creating service user..."
useradd --system --create-home --shell /sbin/nologin notesapp || true

echo "Creating application directory..."
mkdir -p /opt/notesapp
chown notesapp:notesapp /opt/notesapp

echo "Cloning application repository..."
git clone https://github.com/mosesekerin/systems-evolution-lab.git /opt/notesapp
chown -R notesapp:notesapp /opt/notesapp

echo "Making all scripts executable..."
chmod +x /opt/notesapp/bootstrap.sh
chmod +x /opt/notesapp/scripts/*.sh

echo "Server configuration complete."

echo "Setting up the application"
./scripts/setup_notesapp.sh
