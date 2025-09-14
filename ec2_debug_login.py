#!/usr/bin/env python3
"""
EC2 Login Debug Script - Complete Authentication Testing
Run this on your EC2 instance to debug login issues
"""
import os
import sys
import django
from django.test import Client
from django.urls import reverse

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'internet_art_tools.settings')
django.setup()

from users.models import UserAccount
from main_app.models import UserSession

def test_database_connection():
    """Test if database connection is working"""
    print("🔍 Testing Database Connection...")
    print("=" * 50)
    
    try:
        # Test UserAccount model
        total_users = UserAccount.objects.count()
        print(f"✅ Database connection successful!")
        print(f"📊 Total users in UserAccount table: {total_users}")
        
        if total_users > 0:
            print("\n👥 Users found:")
            for user in UserAccount.objects.all():
                print(f"   - Username: {user.user_id}")
                print(f"     Password: {user.password}")
                print(f"     Status: {'Active' if user.status else 'Inactive'}")
                print(f"     Logged in: {'Yes' if user.is_logged_in else 'No'}")
                print(f"     Last login: {user.last_login or 'Never'}")
                print(f"     IP: {user.device_ip or 'None'}")
                print()
        
        return True
        
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        return False

def test_user_authentication():
    """Test user authentication with actual login attempts"""
    print("\n🔐 Testing User Authentication...")
    print("=" * 50)
    
    # Get test users
    users = UserAccount.objects.filter(status=True)[:3]
    
    if not users:
        print("❌ No active users found for testing")
        return False
    
    client = Client()
    
    for user in users:
        print(f"\n🧪 Testing login for user: {user.user_id}")
        print("-" * 30)
        
        # Test main app login
        try:
            response = client.post('/app/login/', {
                'username': user.user_id,
                'password': user.password
            }, follow=True)
            
            if response.status_code == 200:
                # Check if redirected to dashboard
                if '/app/dashboard/' in response.url or response.context:
                    print(f"✅ Main app login successful for {user.user_id}")
                    
                    # Check session data
                    if 'user_id' in client.session:
                        print(f"   Session user_id: {client.session['user_id']}")
                    else:
                        print("   ⚠️ No user_id in session")
                else:
                    print(f"❌ Main app login failed for {user.user_id}")
                    print(f"   Response URL: {response.url}")
                    print(f"   Status Code: {response.status_code}")
            else:
                print(f"❌ Main app login failed for {user.user_id}")
                print(f"   Status Code: {response.status_code}")
                
        except Exception as e:
            print(f"❌ Error testing login for {user.user_id}: {e}")
    
    return True

def test_url_routing():
    """Test if all URLs are properly configured"""
    print("\n🌐 Testing URL Routing...")
    print("=" * 50)
    
    client = Client()
    
    # Test URLs
    test_urls = [
        ('/', 'Root redirect'),
        ('/admin/', 'Django admin'),
        ('/login/', 'Admin login'),
        ('/dashboard/', 'Admin dashboard'),
        ('/app/', 'Main app home'),
        ('/app/login/', 'Main app login'),
        ('/app/dashboard/', 'Main app dashboard'),
    ]
    
    for url, description in test_urls:
        try:
            response = client.get(url)
            print(f"✅ {description}: {url} - Status: {response.status_code}")
        except Exception as e:
            print(f"❌ {description}: {url} - Error: {e}")

def test_template_loading():
    """Test if templates are loading correctly"""
    print("\n📄 Testing Template Loading...")
    print("=" * 50)
    
    try:
        from django.template.loader import get_template
        
        templates = [
            'main_app/login.html',
            'main_app/dashboard.html',
            'users/login.html',
            'users/dashboard.html',
        ]
        
        for template_name in templates:
            try:
                template = get_template(template_name)
                print(f"✅ Template loaded: {template_name}")
            except Exception as e:
                print(f"❌ Template failed: {template_name} - {e}")
                
    except Exception as e:
        print(f"❌ Template loading system error: {e}")

def test_session_management():
    """Test session management"""
    print("\n🔑 Testing Session Management...")
    print("=" * 50)
    
    try:
        from django.contrib.sessions.models import Session
        from django.contrib.sessions.backends.db import SessionStore
        
        # Test session creation
        session = SessionStore()
        session['test_key'] = 'test_value'
        session.save()
        
        print("✅ Session creation successful")
        
        # Test session retrieval
        session_key = session.session_key
        retrieved_session = SessionStore(session_key=session_key)
        
        if retrieved_session.get('test_key') == 'test_value':
            print("✅ Session retrieval successful")
        else:
            print("❌ Session retrieval failed")
            
        # Clean up
        session.delete()
        
    except Exception as e:
        print(f"❌ Session management error: {e}")

def create_test_user():
    """Create a test user if none exist"""
    print("\n👤 Creating Test User...")
    print("=" * 50)
    
    try:
        # Check if test user exists
        if UserAccount.objects.filter(user_id='testuser').exists():
            print("✅ Test user already exists")
            return True
        
        # Create test user
        test_user = UserAccount.objects.create(
            user_id='testuser',
            password='testpass123',
            status=True
        )
        
        print(f"✅ Test user created: {test_user.user_id}")
        print(f"   Password: {test_user.password}")
        print(f"   Status: {'Active' if test_user.status else 'Inactive'}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error creating test user: {e}")
        return False

def main():
    print("🚀 EC2 Login Debug Script - Complete Authentication Test")
    print("=" * 70)
    
    # Test 1: Database connection
    if not test_database_connection():
        print("\n❌ Cannot proceed - database connection failed")
        sys.exit(1)
    
    # Test 2: Create test user if needed
    create_test_user()
    
    # Test 3: URL routing
    test_url_routing()
    
    # Test 4: Template loading
    test_template_loading()
    
    # Test 5: Session management
    test_session_management()
    
    # Test 6: User authentication
    test_user_authentication()
    
    print("\n" + "=" * 70)
    print("📝 Debug Summary:")
    print("1. If all tests pass, login should work")
    print("2. If URL tests fail, check nginx configuration")
    print("3. If template tests fail, check file permissions")
    print("4. If authentication tests fail, check view logic")
    print("5. If session tests fail, check database configuration")
    print("\n🔧 Next Steps:")
    print("- Check Django logs: sudo journalctl -u django -f")
    print("- Check nginx logs: sudo tail -f /var/log/nginx/error.log")
    print("- Restart services: sudo systemctl restart django nginx")

if __name__ == "__main__":
    main()
