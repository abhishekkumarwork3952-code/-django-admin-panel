#!/bin/bash

echo "🚀 Deploying Django Admin Panel from GitHub to EC2..."

# Update system
sudo yum update -y

# Install required packages
sudo yum install -y git python3 python3-pip nginx

# Install EPEL and Certbot
sudo yum install -y epel-release
sudo yum install -y certbot python3-certbot-nginx

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Clone your repository
git clone https://github.com/abhishekkumarwork3952-code/-django-admin-panel.git
cd -django-admin-panel

# Install Python dependencies
pip3 install -r requirements.txt

# Run migrations
python3 manage.py makemigrations
python3 manage.py migrate

# Create superuser
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'admin123')" | python3 manage.py shell

# Collect static files
python3 manage.py collectstatic --noinput

# Create Django service
sudo tee /etc/systemd/system/django.service > /dev/null <<EOF
[Unit]
Description=Django Admin Panel
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/-django-admin-panel
ExecStart=/usr/bin/python3 manage.py runserver 0.0.0.0:8000
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start Django service
sudo systemctl daemon-reload
sudo systemctl start django
sudo systemctl enable django

# Configure Nginx
sudo tee /etc/nginx/nginx.conf > /dev/null <<EOF
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    server {
        listen 80;
        server_name _;

        location /static/ {
            alias /home/ec2-user/-django-admin-panel/staticfiles/;
        }

        location / {
            proxy_pass http://127.0.0.1:8000;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOF

# Restart Nginx
sudo systemctl restart nginx

# Configure firewall
sudo yum install -y firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload

echo "✅ Deployment completed!"
echo ""
echo "🌐 Your admin panel is now available at:"
echo "   http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)/"
echo "   http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)/admin/"
echo ""
echo "🔐 Login credentials:"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo "📱 Service status:"
echo "   Django: sudo systemctl status django"
echo "   Nginx: sudo systemctl status nginx"
