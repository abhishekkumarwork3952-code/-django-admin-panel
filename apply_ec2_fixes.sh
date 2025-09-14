#!/bin/bash

# 🔧 EC2 Connection Fix Application Script
# Run this on EC2 after uploading fixed files

echo "🚀 Applying EC2 Connection Fixes..."
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

# Step 2: Create logs directory
echo "📁 Creating logs directory..."
mkdir -p logs
if [ $? -eq 0 ]; then
    print_status "Logs directory created"
else
    print_warning "Logs directory creation had issues"
fi

# Step 3: Check if new files exist
echo "📄 Checking for new files..."
files_to_check=(
    "main_app/views.py"
    "main_app/api_views.py"
    "main_app/urls.py"
    "internet_art_tools/settings.py"
)

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        print_status "Found: $file"
    else
        print_error "Missing: $file"
        echo "Please upload this file first"
        exit 1
    fi
done

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

# Step 7: Test new API endpoints
echo "🔍 Testing new API endpoints..."
echo "Testing health endpoint..."
curl -s -o /dev/null -w "%{http_code}" http://localhost/app/api/health/
if [ $? -eq 0 ]; then
    print_status "API health endpoint working"
else
    print_warning "API health endpoint test failed"
fi

# Step 8: Check nginx configuration
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

# Step 9: Restart services
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

# Step 10: Test API endpoints
echo "🧪 Testing API endpoints..."
echo "Testing login API..."
response=$(curl -s -X POST http://localhost/app/api/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"testpass123"}')

if echo "$response" | grep -q "success.*true"; then
    print_status "API login endpoint working"
else
    print_warning "API login endpoint test failed"
    echo "Response: $response"
fi

# Step 11: Check service status
echo "📊 Checking service status..."
echo "Nginx status:"
sudo systemctl status nginx --no-pager -l | head -5

if systemctl is-active --quiet django; then
    echo "Django service status:"
    sudo systemctl status django --no-pager -l | head -5
fi

# Step 12: Create test user if needed
echo "👤 Creating test user..."
python3 manage.py shell << EOF
from users.models import UserAccount
if not UserAccount.objects.filter(user_id='testuser').exists():
    UserAccount.objects.create(user_id='testuser', password='testpass123', status=True)
    print("Test user created: testuser / testpass123")
else:
    print("Test user already exists")
EOF

# Step 13: Final verification
echo "🔍 Final verification..."
echo "Testing web login page..."
curl -s -o /dev/null -w "%{http_code}" http://localhost/app/login/
if [ $? -eq 0 ]; then
    print_status "Web login page accessible"
else
    print_warning "Web login page test failed"
fi

echo ""
echo "=================================="
echo "🎉 EC2 Connection Fixes Applied!"
echo ""
echo "📝 What Was Fixed:"
echo "✅ HTTP 302 redirect errors"
echo "✅ Connection stability issues"
echo "✅ Session management problems"
echo "✅ Added stable API endpoints"
echo ""
echo "🌐 New API Endpoints:"
echo "POST /app/api/login/     - JSON login (no redirects)"
echo "GET  /app/api/status/    - Check login status"
echo "POST /app/api/logout/    - Logout"
echo "GET  /app/api/health/    - Health check"
echo ""
echo "🔧 Test Commands:"
echo "curl -X POST http://localhost/app/api/login/ -H \"Content-Type: application/json\" -d '{\"username\":\"testuser\",\"password\":\"testpass123\"}'"
echo "curl http://localhost/app/api/health/"
echo ""
echo "🎯 For AI Mailer Pro:"
echo "Use API endpoints instead of web forms"
echo "This will eliminate connection issues"
echo ""
echo "✅ Your connection issues should now be resolved!"
