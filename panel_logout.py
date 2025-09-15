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
        
        # GET request with parameters
        params = {
            'username': username,
            'password': password
        }
        
        print(f"🔄 Logging out user {username} from panel...")
        
        # Make API call
        response = requests.get(url, params=params, timeout=10)
        
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
            
    except Exception as e:
        print(f"❌ Error calling panel logout API: {e}")
        return False

# Example usage in your AI Mailer Pro logout function:
def your_logout_function():
    """
    Example of how to integrate this into your AI Mailer Pro logout
    """
    # Get current user credentials (replace with your actual variables)
    username = "admin"  # Replace with your username variable
    password = "admin123"  # Replace with your password variable
    
    # Call panel API to logout
    logout_from_panel(username, password)
    
    # Your existing logout code here...
    # For example:
    # self.destroy()
    # show_login_screen()
