# 🔧 **EC2 Integration Fix Guide - "User Does Not Exist" Error**

## 🚨 **Problem Description**
**EC2 pe hosted app mein:**
- ✅ Admin panel mein users create ho rahe hain
- ❌ Main app mein same users login nahi ho rahe
- ❌ Error: "User does not exist"

## 🔍 **Root Cause Analysis**

### **Possible Issues:**
1. **Template Directory Not Configured** - Main app templates not found
2. **Database Connection Mismatch** - Different databases for admin vs main app
3. **URL Routing Issues** - Main app endpoints not properly connected
4. **Environment Variables** - Production vs development settings mismatch

## 🛠️ **Step-by-Step Fix**

### **Step 1: Verify Template Configuration**
```python
# internet_art_tools/settings.py
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [
            BASE_DIR / 'users' / 'templates',
            BASE_DIR / 'main_app' / 'templates',  # ✅ This line is crucial!
        ],
        'APP_DIRS': True,
        # ... rest of config
    },
]
```

### **Step 2: Check Database Configuration**
```python
# internet_art_tools/settings.py
# Database configuration
if config('DATABASE_URL', default=None):
    DATABASES = {
        'default': dj_database_url.parse(config('DATABASE_URL'))
    }
else:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': BASE_DIR / 'db.sqlite3',
        }
    }
```

### **Step 3: Verify URL Configuration**
```python
# internet_art_tools/urls.py
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('users.urls')),  # Admin panel routes
    path('app/', include('main_app.urls')),  # Main app routes ✅
]
```

### **Step 4: Check Installed Apps**
```python
# internet_art_tools/settings.py
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'users',        # ✅ Admin panel app
    'main_app',     # ✅ Main app - CRITICAL!
]
```

## 🧪 **Testing & Debugging**

### **Test 1: Run Database Connection Test**
```bash
# On your EC2 instance
cd /path/to/your/app
python test_db_connection.py
```

**Expected Output:**
```
✅ Database connection successful!
📊 Total users in UserAccount table: 2
👥 Users found:
   - Username: admin
     Status: Active
     Logged in: No
     Last login: Never
     IP: None
```

### **Test 2: Check Django Logs**
```bash
# Check Django application logs
sudo journalctl -u django -f

# Or check nginx logs
sudo tail -f /var/log/nginx/error.log
```

### **Test 3: Verify App URLs**
```bash
# Test if main app endpoints are accessible
curl -I http://your-ec2-ip/app/login/
curl -I http://your-ec2-ip/app/dashboard/
```

## 🔧 **Common Fixes**

### **Fix 1: Template Directory Issue**
```bash
# Ensure main_app templates exist
ls -la main_app/templates/main_app/
# Should show: login.html, dashboard.html
```

### **Fix 2: Database Migration Issue**
```bash
# Run migrations on EC2
python manage.py makemigrations
python manage.py migrate

# Check migration status
python manage.py showmigrations
```

### **Fix 3: Static Files Issue**
```bash
# Collect static files
python manage.py collectstatic --noinput

# Check static files directory
ls -la staticfiles/
```

### **Fix 4: App Registration Issue**
```bash
# Verify main_app is properly installed
python manage.py check main_app

# Should show: System check identified no issues
```

## 🌐 **URL Testing Guide**

### **Admin Panel URLs (Should Work)**
- `http://your-ec2-ip/admin/` → Django admin
- `http://your-ec2-ip/dashboard/` → User management

### **Main App URLs (Should Work After Fix)**
- `http://your-ec2-ip/app/` → Main app home
- `http://your-ec2-ip/app/login/` → Main app login
- `http://your-ec2-ip/app/dashboard/` → Main app dashboard

## 📊 **Debugging Commands**

### **Check Database Content**
```bash
# Connect to database and check users
python manage.py shell

>>> from users.models import UserAccount
>>> UserAccount.objects.all()
>>> UserAccount.objects.count()
```

### **Check App Configuration**
```bash
# Verify Django settings
python manage.py check --deploy

# Check installed apps
python manage.py shell
>>> from django.conf import settings
>>> settings.INSTALLED_APPS
```

### **Check Template Loading**
```bash
# Test template rendering
python manage.py shell

>>> from django.template.loader import get_template
>>> get_template('main_app/login.html')
```

## 🚀 **Production Deployment Checklist**

### **Environment Variables**
```bash
# Set these on your EC2 instance
export SECRET_KEY="your-secret-key"
export DEBUG=False
export ALLOWED_HOSTS="your-ec2-ip,your-domain.com"
export DATABASE_URL="postgresql://user:pass@host:port/db"
```

### **Service Restart**
```bash
# Restart Django service
sudo systemctl restart django

# Restart nginx
sudo systemctl restart nginx

# Check service status
sudo systemctl status django
sudo systemctl status nginx
```

### **File Permissions**
```bash
# Ensure proper file ownership
sudo chown -R django:django /var/www/django
sudo chmod -R 755 /var/www/django
```

## 🔍 **Troubleshooting Steps**

### **If Still Getting "User Does Not Exist":**

1. **Check Database Connection**
   ```bash
   python test_db_connection.py
   ```

2. **Verify User Creation**
   ```bash
   # Go to admin panel and create a test user
   # Then check if it appears in database
   ```

3. **Check Django Logs**
   ```bash
   sudo journalctl -u django -f
   ```

4. **Test User Lookup**
   ```bash
   python manage.py shell
   >>> from users.models import UserAccount
   >>> UserAccount.objects.get(user_id='testuser')
   ```

## ✅ **Success Indicators**

After applying fixes, you should see:

1. **Database Test Passes**
   ```
   ✅ Database connection successful!
   📊 Total users in UserAccount table: X
   ```

2. **Main App Login Works**
   - Users can login with credentials created in admin panel
   - No more "User does not exist" errors

3. **Real-time Sync**
   - User status updates in admin panel when they login
   - Session information is tracked

## 🆘 **Still Having Issues?**

### **Emergency Debug Mode**
```python
# Add this to main_app/views.py temporarily
import logging
logger = logging.getLogger(__name__)

def main_login(request):
    logger.error(f"Login attempt: {request.POST}")
    # ... rest of function
```

### **Check Django Version Compatibility**
```bash
python -c "import django; print(django.get_version())"
# Should be Django 5.2.5 or compatible
```

---

## 🎯 **Quick Fix Summary**

1. **Verify main_app in INSTALLED_APPS** ✅
2. **Check template directory configuration** ✅
3. **Run database connection test** ✅
4. **Restart Django service** ✅
5. **Test main app login** ✅

**Ab aapka EC2 integration perfectly work karega!** 🚀
