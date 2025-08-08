import csv
import mysql.connector

# === CONFIGURATION ===
csv_file = "matched_images_output.csv"
db_config = {
    'host': 'mysql2-p2.ezhostingserver.com',
    'user': 'sanjay',
    'password': 'BU@R9gr2971{',
    'database': 'interview_helper'
}
table_name = 'happy_hours_bangkok'

# === STEP 1: TEST CONNECTION ===
try:
    print("🔌 Testing MySQL connection...")
    conn = mysql.connector.connect(**db_config)
    print("✅ Connection to MySQL successful.")
except mysql.connector.Error as err:
    print(f"❌ Connection failed: {err}")
    exit(1)

cursor = conn.cursor()
updated_rows = 0

# === STEP 2: PROCESS CSV AND UPDATE DATABASE ===
try:
    with open(csv_file, mode='r', encoding='utf-8') as f:
        reader = csv.DictReader(f)

        for row in reader:
            name = row.get('Name')
            column_to_update = row.get('Column')  # Should be "Image" or "Logo"
            image_filename = row.get('MatchedFile')  # File name to update with

            if not name or not column_to_update or not image_filename:
                continue  # Skip rows with missing fields

            if column_to_update not in ['Image', 'Logo']:
                print(f"⚠️ Unknown column '{column_to_update}' for Name: {name}")
                continue

            try:
                sql = f"UPDATE {table_name} SET {column_to_update} = %s WHERE Name = %s"
                cursor.execute(sql, (image_filename, name))
                print(f"✅ Updated {column_to_update} for '{name}' → {image_filename}")
                updated_rows += 1
            except Exception as e:
                print(f"❌ Error updating {column_to_update} for '{name}': {e}")

    conn.commit()

except FileNotFoundError:
    print(f"❌ CSV file '{csv_file}' not found.")
except Exception as e:
    print(f"❌ Unexpected error: {e}")
finally:
    cursor.close()
    conn.close()
    print(f"\n🔁 Done. Total updated rows: {updated_rows}")
