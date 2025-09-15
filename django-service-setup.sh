#!/bin/bash

# Django Service Setup Script
# This will create a permanent systemd service for Django

echo "🔧 Setting up Django as a permanent service..."

# Create systemd service file
sudo tee /etc/systemd/system/django-panel.service > /dev/null <<EOF
[Unit]
Description=Django Panel Service
After=network.target

[Service]
Type=simple
User=ec2-user
Group=ec2-user
WorkingDirectory=/home/ec2-user/-django-admin-panel
Environment=PATH=/home/ec2-user/.local/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=/usr/bin/python3 manage.py runserver 0.0.0.0:8000
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

echo "✅ Service file created"

# Reload systemd
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable django-panel.service

# Start the service
sudo systemctl start django-panel.service

# Check service status
echo "📊 Service Status:"
sudo systemctl status django-panel.service

echo "🎉 Django service setup complete!"
echo "📋 Commands to manage service:"
echo "  Start:   sudo systemctl start django-panel"
echo "  Stop:    sudo systemctl stop django-panel"
echo "  Restart: sudo systemctl restart django-panel"
echo "  Status:  sudo systemctl status django-panel"
echo "  Logs:    sudo journalctl -u django-panel -f"
