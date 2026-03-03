import requests

def test_url(url, name):
    print(f"\nTesting {name}...\nURL: {url}")
    try:
        response = requests.get(url, timeout=5)
        print(f"[{name}] Status: {response.status_code}")
        if response.status_code == 200:
             print(f"Success! Response preview: {response.text[:100]}...")
             return True
        else:
             print(f"Failed with status {response.status_code}")
             return False
    except Exception as e:
        print(f"[{name}] FAILED: {type(e).__name__}: {str(e)}")
        return False

print("Starting Alternative API Test...")

# 1. BigDataCloud Reverse Geocoding (Free, no key)
bdc_ok = test_url(
    "https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=18.6&longitude=73.7&localityLanguage=en", 
    "BigDataCloud Reverse"
)

# 2. Open-Meteo Geocoding Search (Free, no key)
om_ok = test_url(
    "https://geocoding-api.open-meteo.com/v1/search?name=Pune&count=1&language=en&format=json",
    "Open-Meteo Search"
)
