#!/bin/bash
set -e

echo "Starting NotesApp service..."
sudo systemctl start notesapp

echo "Enabling service at boot..."
sudo systemctl enable notesapp

echo "Deployment complete."
echo "Check logs with: tail -f /var/log/notesapp.log"
echo "Check status with: sudo systemctl status notesapp"