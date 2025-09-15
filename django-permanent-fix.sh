#!/bin/bash

# Django Permanent Fix Script
echo "🔧 Setting up Django as permanent service..."

# Navigate to Django directory
cd /home/ec2-user/-django-admin-panel

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
Environment=PYTHONPATH=/home/ec2-user/-django-admin-panel
ExecStart=/usr/bin/python3 manage.py runserver 0.0.0.0:8000
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal
KillMode=mixed
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "✅ Service file created"

# Reload systemd
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable django-panel.service

# Stop any existing Django processes
pkill -f "python3 manage.py runserver"
sudo fuser -k 8000/tcp 2>/dev/null

# Start the service
sudo systemctl start django-panel.service

# Wait a moment
sleep 3

# Check service status
echo "📊 Service Status:"
sudo systemctl status django-panel.service --no-pager

# Check if Django is responding
echo "🧪 Testing Django server..."
if curl -s http://localhost:8000 > /dev/null; then
    echo "✅ Django server is responding!"
else
    echo "❌ Django server is not responding"
    echo "📋 Check logs: sudo journalctl -u django-panel -f"
fi

echo "🎉 Django service setup complete!"
echo "📋 Management commands:"
echo "  Start:   sudo systemctl start django-panel"
echo "  Stop:    sudo systemctl stop django-panel"
echo "  Restart: sudo systemctl restart django-panel"
echo "  Status:  sudo systemctl status django-panel"
echo "  Logs:    sudo journalctl -u django-panel -f"