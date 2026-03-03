from fastapi import APIRouter, HTTPException, Query
import requests

router = APIRouter()

from app.core.config import settings

@router.get("/reverse")
def reverse_geocode(lat: float, lon: float):
    if not settings.GOOGLE_MAPS_API_KEY:
        raise HTTPException(status_code=500, detail="Google Maps API Key not configured in backend.")

    try:
        # Google Geocoding API
        url = "https://maps.googleapis.com/maps/api/geocode/json"
        params = {
            "latlng": f"{lat},{lon}",
            "key": settings.GOOGLE_MAPS_API_KEY
        }
        
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        if data['status'] != 'OK':
             print(f"Google API Error: {data.get('error_message')}")
             raise Exception(f"Google API Error: {data.get('status')}")

        # Extract address components
        result = data['results'][0]
        address_components = result.get('address_components', [])
        
        city = ''
        state = ''
        country = ''
        
        for comp in address_components:
            types = comp.get('types', [])
            if 'locality' in types:
                city = comp['long_name']
            elif 'administrative_area_level_1' in types:
                state = comp['long_name']
            elif 'country' in types:
                country = comp['long_name']
        
        # Fallback if city is missing (e.g. use admin_area_level_2)
        if not city:
             for comp in address_components:
                if 'administrative_area_level_2' in types:
                    city = comp['long_name']
                    break

        return {
            "address": {
                "city": city,
                "state": state,
                "country": country
            },
            "display_name": result.get('formatted_address', '')
        }

    except Exception as e:
        print(f"Error in reverse_geocode: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch location: {str(e)}")

@router.get("/search")
def search_location(q: str):
    if not settings.GOOGLE_MAPS_API_KEY:
        raise HTTPException(status_code=500, detail="Google Maps API Key not configured in backend.")

    try:
        # Google Places Autocomplete API
        url = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        params = {
            "input": q,
            "key": settings.GOOGLE_MAPS_API_KEY,
            # "types": "(cities)", # Optional: restrict to cities
        }
        
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        if data['status'] != 'OK':
             # ZERO_RESULTS is distinct from error
             if data['status'] == 'ZERO_RESULTS':
                 return []
             print(f"Google API Error: {data.get('error_message')}")
             raise Exception(f"Google API Error: {data.get('status')}")
        
        results = []
        for prediction in data.get('predictions', []):
            description = prediction.get('description', '')
            structured_formatting = prediction.get('structured_formatting', {})
            
            main_text = structured_formatting.get('main_text', '')
            secondary_text = structured_formatting.get('secondary_text', '')
            
            # Simple parsing for city/state (Google doesn't give structured components in autocomplete easily without Details API)
            # We will use the main_text as city/name and secondary as context
            
            results.append({
                "display_name": description,
                "address": {
                    "city": main_text,
                    "state": secondary_text, # Approximate
                    "country": ""
                },
                # Autocomplete doesn't give lat/lon directly. 
                # Ideally we call Place Details API, but for search suggestion list, we might not need it yet unless frontend requires it for result selection.
                # However, our frontend search just takes the string location.
            })
        
        return results

    except Exception as e:
        print(f"Error in search_location: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to search location: {str(e)}")
