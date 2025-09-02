#!/bin/bash

# EC2 Setup Script for Django Admin Panel with HTTPS
# Run this on your EC2 instance

echo "🚀 Setting up Django Admin Panel on EC2 with HTTPS support..."

# Update system
echo "📦 Updating system packages..."
sudo yum update -y

# Install required packages
echo "🔧 Installing required packages..."
sudo yum install -y nginx python3 python3-pip git

# Install EPEL repository for additional packages
sudo yum install -y epel-release

# Install Certbot for SSL certificates
echo "🔐 Installing Certbot for SSL certificates..."
sudo yum install -y certbot python3-certbot-nginx

# Start and enable Nginx
echo "🌐 Starting Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Create Django user
echo "👤 Creating Django user..."
sudo useradd -r -s /bin/false django

# Create application directory
echo "📁 Creating application directory..."
sudo mkdir -p /var/www/django
sudo chown django:django /var/www/django

# Clone your repository (replace with your repo URL)
echo "📥 Cloning your Django application..."
cd /var/www/django
sudo -u django git clone <YOUR_REPO_URL> .

# Install Python dependencies
echo "🐍 Installing Python dependencies..."
sudo -u django pip3 install -r requirements.txt

# Collect static files
echo "📦 Collecting static files..."
sudo -u django python3 manage.py collectstatic --noinput

# Create static files directory
sudo mkdir -p /var/www/staticfiles
sudo chown -R django:django /var/www/staticfiles

# Copy static files
sudo cp -r staticfiles/* /var/www/staticfiles/

# Create media directory
sudo mkdir -p /var/www/media
sudo chown -R django:django /var/www/media

# Create Django service file
echo "⚙️ Creating Django service..."
sudo tee /etc/systemd/system/django.service > /dev/null <<EOF
[Unit]
Description=Django Admin Panel
After=network.target

[Service]
Type=simple
User=django
Group=django
WorkingDirectory=/var/www/django
ExecStart=/usr/bin/python3 manage.py runserver 127.0.0.1:8000
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start Django
echo "🔄 Starting Django service..."
sudo systemctl daemon-reload
sudo systemctl start django
sudo systemctl enable django

# Configure Nginx
echo "🔧 Configuring Nginx..."
sudo cp nginx.conf /etc/nginx/nginx.conf

# Test Nginx configuration
echo "🧪 Testing Nginx configuration..."
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Configure firewall
echo "🔥 Configuring firewall..."
sudo yum install -y firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Open ports
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload

echo "✅ Basic setup completed!"
echo ""
echo "🌐 Next steps:"
echo "1. Update nginx.conf with your domain name"
echo "2. Get SSL certificate: sudo certbot --nginx -d your-domain.com"
echo "3. Restart Nginx: sudo systemctl restart nginx"
echo ""
echo "🔐 Your admin panel will be available at:"
echo "   - HTTP: http://your-domain.com/admin/"
echo "   - HTTPS: https://your-domain.com/admin/"
echo ""
echo "📱 Django service status: sudo systemctl status django"
echo "🌐 Nginx service status: sudo systemctl status nginx"
