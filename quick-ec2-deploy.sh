#!/bin/bash

echo "🚀 Quick EC2 Deployment for Django Admin Panel..."

# Update system
sudo yum update -y

# Install packages
sudo yum install -y nginx python3 python3-pip git

# Install EPEL and Certbot
sudo yum install -y epel-release
sudo yum install -y certbot python3-certbot-nginx

# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Create app directory
sudo mkdir -p /var/www/django
cd /var/www/django

# Create Django project structure
sudo mkdir -p internet_art_tools users staticfiles

# Create requirements.txt
sudo tee requirements.txt > /dev/null <<EOF
Django>=5.0,<6.0
gunicorn>=21.0.0
psycopg2-binary>=2.9.0
whitenoise>=6.5.0
dj-database-url>=2.0.0
python-decouple>=3.8
boto3>=1.26.0
EOF

# Install Python packages
sudo pip3 install -r requirements.txt

# Create Django settings
sudo tee internet_art_tools/settings.py > /dev/null <<EOF
from pathlib import Path
import os

BASE_DIR = Path(__file__).resolve().parent.parent
SECRET_KEY = 'django-insecure-quick-deploy-key'
DEBUG = False
ALLOWED_HOSTS = ['*']

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'users',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'internet_art_tools.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'users' / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'internet_art_tools.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

AUTH_PASSWORD_VALIDATORS = []

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'Asia/Kolkata'
USE_I18N = True
USE_TZ = True

STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATICFILES_DIRS = [BASE_DIR / 'users' / 'static']

STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

LOGIN_URL = 'login'
LOGIN_REDIRECT_URL = 'dashboard'
LOGOUT_REDIRECT_URL = 'login'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
EOF

# Create __init__.py files
sudo touch internet_art_tools/__init__.py
sudo touch users/__init__.py

# Create manage.py
sudo tee manage.py > /dev/null <<EOF
#!/usr/bin/env python
import os
import sys

def main():
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'internet_art_tools.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed?"
        ) from exc
    execute_from_command_line(sys.argv)

if __name__ == '__main__':
    main()
EOF

# Create users model
sudo tee users/models.py > /dev/null <<EOF
from django.db import models

class UserAccount(models.Model):
    user_id = models.CharField(max_length=50, unique=True)
    password = models.CharField(max_length=255)
    status = models.BooleanField(default=True)
    is_logged_in = models.BooleanField(default=False)
    device_ip = models.GenericIPAddressField(null=True, blank=True)
    last_login = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return self.user_id
EOF

# Create users admin
sudo tee users/admin.py > /dev/null <<EOF
from django.contrib import admin
from .models import UserAccount

@admin.register(UserAccount)
class UserAccountAdmin(admin.ModelAdmin):
    list_display = ('user_id','status','is_logged_in','device_ip','last_login')
    search_fields = ('user_id',)
EOF

# Create users apps
sudo tee users/apps.py > /dev/null <<EOF
from django.apps import AppConfig

class UsersConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'users'
EOF

# Create main URLs
sudo tee internet_art_tools/urls.py > /dev/null <<EOF
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('users.urls')),
]
EOF

# Create users URLs
sudo tee users/urls.py > /dev/null <<EOF
from django.urls import path
from . import views

urlpatterns = [
    path('', views.login_view, name='login'),
    path('dashboard/', views.dashboard, name='dashboard'),
    path('logout/', views.logout_view, name='logout'),
]
EOF

# Create users views
sudo tee users/views.py > /dev/null <<EOF
from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required

def login_view(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            return redirect('dashboard')
    return render(request, 'users/login.html')

@login_required
def dashboard(request):
    return render(request, 'users/dashboard.html')

def logout_view(request):
    logout(request)
    return redirect('login')
EOF

# Create templates directory
sudo mkdir -p users/templates/users

# Create login template
sudo tee users/templates/users/login.html > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Admin Login</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .login-container { max-width: 400px; margin: 100px auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        input { width: 100%; padding: 10px; margin: 10px 0; border: 1px solid #ddd; border-radius: 5px; }
        button { width: 100%; padding: 10px; background: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer; }
        button:hover { background: #0056b3; }
    </style>
</head>
<body>
    <div class="login-container">
        <h2>Admin Panel Login</h2>
        <form method="post">
            {% csrf_token %}
            <input type="text" name="username" placeholder="Username" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit">Login</button>
        </form>
    </div>
</body>
</html>
EOF

# Create dashboard template
sudo tee users/templates/users/dashboard.html > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .dashboard { max-width: 800px; margin: 50px auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .logout { padding: 10px 20px; background: #dc3545; color: white; text-decoration: none; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="dashboard">
        <div class="header">
            <h1>Admin Dashboard</h1>
            <a href="/logout/" class="logout">Logout</a>
        </div>
        <p>Welcome to your Django Admin Panel!</p>
        <p><a href="/admin/">Go to Django Admin</a></p>
    </div>
</body>
</html>
EOF

# Set permissions
sudo chown -R ec2-user:ec2-user /var/www/django

# Run migrations
cd /var/www/django
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
WorkingDirectory=/var/www/django
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
            alias /var/www/django/staticfiles/;
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

echo "✅ Quick deployment completed!"
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
