import requests
import json

def logout_from_panel(username, password):
    """
    Call the panel API to logout user automatically
    This function should be called when user logs out from AI Mailer Pro
    """
    try:
        # Panel API endpoint
        url = "http://16.170.250.233:8000/api/logout/"
        
        # Method 1: GET request with parameters
        params = {
            'username': username,
            'password': password
        }
        
        print(f"🔄 Calling panel logout API for user: {username}")
        
        # Make API call
        response = requests.get(url, params=params, timeout=10)
        
        print(f"📡 API Response Status: {response.status_code}")
        print(f"📡 API Response: {response.text}")
        
        if response.status_code == 200:
            data = response.json()
            if data.get('status') == 'success':
                print(f"✅ User {username} logged out from panel successfully")
                return True
            else:
                print(f"❌ Panel logout failed: {data.get('message')}")
                return False
        else:
            print(f"❌ Panel logout failed with status code: {response.status_code}")
            return False
            
    except requests.exceptions.Timeout:
        print("❌ Panel logout API timeout - panel might be down")
        return False
    except requests.exceptions.ConnectionError:
        print("❌ Panel logout API connection error - check network")
        return False
    except Exception as e:
        print(f"❌ Error calling panel logout API: {e}")
        return False

# Test function - you can call this to test the API
def test_panel_logout():
    """
    Test function to verify the API is working
    """
    print("🧪 Testing panel logout API...")
    
    # Test with admin user
    result = logout_from_panel("admin", "admin123")
    
    if result:
        print("✅ Test successful - API is working!")
    else:
        print("❌ Test failed - check panel status")

if __name__ == "__main__":
    # Run test when file is executed directly
    test_panel_logout()
