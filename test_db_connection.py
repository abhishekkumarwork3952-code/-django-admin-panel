#!/usr/bin/env python3
"""
Test script to verify database connection and user data
Run this on your EC2 instance to debug the integration issue
"""
import os
import sys
import django

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
                print(f"     Status: {'Active' if user.status else 'Inactive'}")
                print(f"     Logged in: {'Yes' if user.is_logged_in else 'No'}")
                print(f"     Last login: {user.last_login or 'Never'}")
                print(f"     IP: {user.device_ip or 'None'}")
                print()
        
        # Test UserSession model
        total_sessions = UserSession.objects.count()
        print(f"📱 Total sessions in UserSession table: {total_sessions}")
        
        if total_sessions > 0:
            print("\n🔄 Recent sessions:")
            for session in UserSession.objects.order_by('-session_start')[:5]:
                print(f"   - User: {session.user_account.user_id}")
                print(f"     Start: {session.session_start}")
                print(f"     End: {session.session_end or 'Active'}")
                print(f"     IP: {session.ip_address}")
                print()
        
        return True
        
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        return False

def test_user_lookup(username):
    """Test if a specific user can be found"""
    print(f"\n🔍 Testing user lookup for: {username}")
    print("-" * 30)
    
    try:
        user = UserAccount.objects.get(user_id=username)
        print(f"✅ User found: {user.user_id}")
        print(f"   Status: {'Active' if user.status else 'Inactive'}")
        print(f"   Password: {user.password}")
        print(f"   Logged in: {'Yes' if user.is_logged_in else 'No'}")
        return True
    except UserAccount.DoesNotExist:
        print(f"❌ User '{username}' not found in database")
        return False
    except Exception as e:
        print(f"❌ Error looking up user: {e}")
        return False

def main():
    print("🚀 Database Connection Test for EC2 Integration")
    print("=" * 60)
    
    # Test database connection
    if not test_database_connection():
        print("\n❌ Cannot proceed - database connection failed")
        sys.exit(1)
    
    # Test specific users
    test_users = ['admin', 'testuser']
    for username in test_users:
        test_user_lookup(username)
    
    print("\n" + "=" * 60)
    print("📝 Next Steps:")
    print("1. If users are found, check main app login form")
    print("2. If no users found, create users in admin panel first")
    print("3. Check Django logs for any errors")
    print("4. Verify DATABASE_URL in environment variables")

if __name__ == "__main__":
    main()
