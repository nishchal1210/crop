# from flask import Flask, request, jsonify, render_template
# import requests

# app = Flask(__name__)

# # Replace with your actual Google Maps API key
# GOOGLE_MAPS_API_KEY = 'AIzaSyCXAnXUw4AkszwlpJV8vBmnzbzv0Ik2SQA'

# @app.route('/')
# def index():
#     return render_template('index.html')

# @app.route('/vendors', methods=['GET'])
# def get_vendors():
#     # Get the latitude and longitude directly from the request parameters
#     latitude = request.args.get('lat')
#     longitude = request.args.get('lng')
    
#     if not latitude or not longitude:
#         return jsonify({"error": "Please provide valid latitude and longitude"}), 400
    
#     # Define the search query and parameters
#     search_query = 'seed manure pesticide vendors'
#     location = f"{latitude},{longitude}"
#     radius = 5000  # Search within a 5km radius
    
#     # Make a request to the Google Maps Places API
#     url = f"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={location}&radius={radius}&keyword={search_query}&key={GOOGLE_MAPS_API_KEY}"
    
#     response = requests.get(url)
    
#     if response.status_code == 200:
#         data = response.json()
#         # Extract relevant vendor information
#         vendors = []
#         for result in data.get('results', []):
#             vendor = {
#                 "name": result.get('name'),
#                 "address": result.get('vicinity'),
#                 "rating": result.get('rating'),
#                 "location": result.get('geometry', {}).get('location')
#             }
#             vendors.append(vendor)
        
#         return jsonify({"vendors": vendors}), 200
#     else:
#         return jsonify({"error": "Failed to fetch vendor data"}), 500

# @app.route('/geocode', methods=['GET'])
# def geocode_address():
#     address = request.args.get('address')
#     if not address:
#         return jsonify({"error": "Please provide an address"}), 400
    
#     # Make a request to Google Geocoding API
#     geocode_url = f"https://maps.googleapis.com/maps/api/geocode/json?address={address}&key={GOOGLE_MAPS_API_KEY}"
#     geocode_response = requests.get(geocode_url)
    
#     if geocode_response.status_code == 200:
#         geocode_data = geocode_response.json()
#         if geocode_data['status'] == 'OK':
#             location = geocode_data['results'][0]['geometry']['location']
#             lat = location['lat']
#             lng = location['lng']
#             return jsonify({"lat": lat, "lng": lng}), 200
#         else:
#             return jsonify({"error": "Geocoding failed"}), 500
#     else:
#         return jsonify({"error": "Failed to fetch geocoding data"}), 500

# if __name__ == '__main__':
#     app.run(debug=True)
