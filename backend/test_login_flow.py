import requests
import sys

BASE_URL = "http://127.0.0.1:8000/api/v1/auth"
TEST_EMAIL = "test_user_verify@example.com"
TEST_PASSWORD = "testpassword123"
TEST_NAME = "Test User Verify"

def run_test():
    try:
        # 1. Register
        print(f"1. Attempting to register user: {TEST_EMAIL}")
        payload = {
            "email": TEST_EMAIL,
            "password": TEST_PASSWORD,
            "name": TEST_NAME,
            "role": "renter"
        }
        response = requests.post(f"{BASE_URL}/register", json=payload)
        
        if response.status_code == 201:
            print("   [SUCCESS] Registration successful.")
        elif response.status_code == 400 and "already registered" in response.text:
             print("   [INFO] User already exists, proceeding to login.")
        else:
            print(f"   [FAILED] Registration failed: {response.status_code} - {response.text}")
            return

        # 2. Login
        print(f"\n2. Attempting to login user: {TEST_EMAIL}")
        # OAuth2PasswordRequestForm expects 'username' and 'password' form data
        login_data = {
            "username": TEST_EMAIL,
            "password": TEST_PASSWORD
        }
        response = requests.post(f"{BASE_URL}/login", data=login_data)
        
        if response.status_code == 200:
            token_data = response.json()
            print("   [SUCCESS] Login successful!")
            print(f"   Context: Access Token: {token_data.get('access_token')[:20]}...")
        else:
            print(f"   [FAILED] Login failed: {response.status_code} - {response.text}")

    except Exception as e:
        print(f"   [ERROR] An error occurred: {e}")

if __name__ == "__main__":
    run_test()
