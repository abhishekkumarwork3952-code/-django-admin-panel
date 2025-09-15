import requests

def test_logout():
    try:
        url = "http://16.170.250.233:8000/api/logout/"
        params = {
            'username': 'admin',
            'password': 'admin123'
        }
        
        print("🔄 Testing panel logout API...")
        response = requests.get(url, params=params, timeout=10)
        
        print(f"📡 Status Code: {response.status_code}")
        print(f"📡 Response: {response.text}")
        
        if response.status_code == 200:
            data = response.json()
            if data.get('status') == 'success':
                print("✅ API test successful!")
                return True
        
        print("❌ API test failed!")
        return False
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    test_logout()
