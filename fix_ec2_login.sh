#!/bin/bash

# 🔧 EC2 Login Fix Script
# Run this on your EC2 instance to fix login issues

echo "🚀 Starting EC2 Login Fix Process..."
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Step 1: Check if we're in the right directory
echo "📁 Checking directory structure..."
if [ ! -f "manage.py" ]; then
    print_error "manage.py not found. Please run this script from your Django project root."
    exit 1
fi
print_status "Django project found"

# Step 2: Check Python and Django
echo "🐍 Checking Python environment..."
python3 --version
if [ $? -eq 0 ]; then
    print_status "Python3 is available"
else
    print_error "Python3 not found"
    exit 1
fi

# Step 3: Install/Update dependencies
echo "📦 Installing/Updating dependencies..."
pip3 install -r requirements.txt
if [ $? -eq 0 ]; then
    print_status "Dependencies installed successfully"
else
    print_warning "Some dependencies might have issues"
fi

# Step 4: Run database migrations
echo "🗄️ Running database migrations..."
python3 manage.py makemigrations
python3 manage.py migrate
if [ $? -eq 0 ]; then
    print_status "Database migrations completed"
else
    print_error "Database migration failed"
    exit 1
fi

# Step 5: Collect static files
echo "📁 Collecting static files..."
python3 manage.py collectstatic --noinput
if [ $? -eq 0 ]; then
    print_status "Static files collected"
else
    print_warning "Static files collection had issues"
fi

# Step 6: Check Django configuration
echo "⚙️ Checking Django configuration..."
python3 manage.py check --deploy
if [ $? -eq 0 ]; then
    print_status "Django configuration is valid"
else
    print_warning "Django configuration has warnings"
fi

# Step 7: Test database connection
echo "🔍 Testing database connection..."
python3 ec2_debug_login.py
if [ $? -eq 0 ]; then
    print_status "Database connection test completed"
else
    print_error "Database connection test failed"
fi

# Step 8: Check file permissions
echo "🔐 Setting proper file permissions..."
sudo chown -R $USER:$USER .
chmod -R 755 .
print_status "File permissions set"

# Step 9: Check nginx configuration
echo "🌐 Checking nginx configuration..."
if [ -f "/etc/nginx/sites-available/django" ]; then
    sudo nginx -t
    if [ $? -eq 0 ]; then
        print_status "Nginx configuration is valid"
    else
        print_error "Nginx configuration has errors"
    fi
else
    print_warning "Nginx configuration file not found"
fi

# Step 10: Restart services
echo "🔄 Restarting services..."
sudo systemctl restart nginx
if [ $? -eq 0 ]; then
    print_status "Nginx restarted successfully"
else
    print_error "Failed to restart nginx"
fi

# Check if Django service exists
if systemctl is-active --quiet django; then
    sudo systemctl restart django
    if [ $? -eq 0 ]; then
        print_status "Django service restarted successfully"
    else
        print_error "Failed to restart Django service"
    fi
else
    print_warning "Django service not found - you might be using a different process manager"
fi

# Step 11: Check service status
echo "📊 Checking service status..."
echo "Nginx status:"
sudo systemctl status nginx --no-pager -l

if systemctl is-active --quiet django; then
    echo "Django service status:"
    sudo systemctl status django --no-pager -l
fi

# Step 12: Test URLs
echo "🌐 Testing application URLs..."
echo "Testing main app login page..."
curl -I http://localhost/app/login/ 2>/dev/null | head -1

echo "Testing admin panel..."
curl -I http://localhost/admin/ 2>/dev/null | head -1

# Step 13: Create test user if needed
echo "👤 Creating test user..."
python3 manage.py shell << EOF
from users.models import UserAccount
if not UserAccount.objects.filter(user_id='testuser').exists():
    UserAccount.objects.create(user_id='testuser', password='testpass123', status=True)
    print("Test user created: testuser / testpass123")
else:
    print("Test user already exists")
EOF

# Step 14: Final verification
echo "🔍 Final verification..."
echo "Running comprehensive debug test..."
python3 ec2_debug_login.py

echo ""
echo "=================================="
echo "🎉 EC2 Login Fix Process Complete!"
echo ""
echo "📝 Next Steps:"
echo "1. Test login at: http://your-ec2-ip/app/login/"
echo "2. Use credentials: testuser / testpass123"
echo "3. Check logs if issues persist:"
echo "   - Django: sudo journalctl -u django -f"
echo "   - Nginx: sudo tail -f /var/log/nginx/error.log"
echo ""
echo "🔧 If still having issues:"
echo "1. Check ALLOWED_HOSTS in settings.py"
echo "2. Verify DATABASE_URL environment variable"
echo "3. Check firewall settings (ports 80, 443)"
echo "4. Verify domain/DNS configuration"
echo ""
echo "✅ Your login system should now work properly!"
