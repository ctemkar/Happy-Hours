import mysql.connector
from geopy.geocoders import Nominatim
from geopy.exc import GeocoderTimedOut
import time

# MySQL connection settings
DB_HOST = "mysql2-p2.ezhostingserver.com"
DB_USER = "sanjay"
DB_PASSWORD = "BU@R9gr2971{"  # Change if your MySQL password is set
DB_NAME = "interview_helper"

# Function to get latitude & longitude from address
def get_lat_lon(address):
    try:
        location = geolocator.geocode(address, timeout=10)
        if location:
            return location.latitude, location.longitude
        else:
            return None, None
    except GeocoderTimedOut:
        return None, None

# Connect to MySQL
conn = mysql.connector.connect(
    host=DB_HOST,
    user=DB_USER,
    password=DB_PASSWORD,
    database=DB_NAME
)
cursor = conn.cursor()

# Initialize geolocator
geolocator = Nominatim(user_agent="happy_hours_bangkok_locator")

# Fetch all rows with empty latitude/longitude
cursor.execute("SELECT happy_hours_id, Address FROM happy_hours_bangkok WHERE latitude IS NULL OR longitude IS NULL")
rows = cursor.fetchall()

for row in rows:
    happy_hours_id, address = row
    if address and address.strip():
        print(f"Fetching lat/lon for: {address}")
        lat, lon = get_lat_lon(address)
        if lat and lon:
            cursor.execute(
                "UPDATE happy_hours_bangkok SET latitude=%s, longitude=%s WHERE happy_hours_id=%s",
                (lat, lon, happy_hours_id)
            )
            conn.commit()
            print(f"Updated: {lat}, {lon}")
        else:
            print("Could not fetch coordinates")
        time.sleep(1)  # Sleep to avoid being blocked by Nominatim

# Close connection
cursor.close()
conn.close()
print("✅ Latitude & Longitude update complete.")
