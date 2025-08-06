import pandas as pd
import mysql.connector
import os

def read_image(file_path):
    if pd.isna(file_path) or not isinstance(file_path, str):
        return None
    if not os.path.isfile(file_path.strip()):
        print(f"⚠️ File not found: {file_path}")
        return None
    with open(file_path.strip(), "rb") as f:
        return f.read()

# === Step 1: Load Excel ===
try:
    df = pd.read_excel("happy_hour.xlsx", sheet_name="REAL ONE")
    df.columns = df.columns.str.strip().str.lower()  # Normalize column names
    print("📋 Actual column names found in Excel:")
    print(df.columns.tolist())
except Exception as e:
    print("❌ Failed to load Excel file:", e)
    exit()

# Check required columns
required_cols = ['name', 'address', 'image', 'logo']
for col in required_cols:
    if col not in df.columns:
        print(f"❌ Missing required column: {col}")
        exit()

# === Step 2: Connect to MySQL ===
try:
    conn = mysql.connector.connect(
        host='mysql2-p2.ezhostingserver.com',
        user='sanjay',
        password='BU@R9gr2971{',
        database='interview_helper'
    )
    cursor = conn.cursor()
    print("✅ Connected to MySQL")
except mysql.connector.Error as err:
    print("❌ MySQL Error:", err)
    exit()

# === Step 3: Update each row based on Name + Address ===
update_query = """
    UPDATE happy_hours_bangkok
    SET image = %s, logo = %s
    WHERE Name = %s AND Address = %s
"""

updated_count = 0
for index, row in df.iterrows():
    name = row.get("name")
    address = row.get("address")

    if pd.isna(name) or pd.isna(address):
        print(f"⚠️ Skipping row {index} due to missing Name or Address")
        continue

    image_blob = read_image(row.get("image"))
    logo_blob = read_image(row.get("logo"))

    try:
        cursor.execute(update_query, (image_blob, logo_blob, name.strip(), address.strip()))
        if cursor.rowcount > 0:
            updated_count += 1
        else:
            print(f"⚠️ No match found in DB for row {index}: Name='{name}', Address='{address}'")
    except Exception as e:
        print(f"❌ Error updating row {index}: {e}")

# Commit and close
conn.commit()
cursor.close()
conn.close()

print(f"✅ {updated_count} rows updated successfully.")
