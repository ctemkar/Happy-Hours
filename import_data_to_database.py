import pandas as pd
import pymysql
import uuid
import math

# Define clean() to convert NaN to None and strip spaces
def clean(val):
    return None if pd.isna(val) or (isinstance(val, float) and math.isnan(val)) else str(val).strip()

# CSV file path
file_path = 'happyhoursreal.csv'

# Load CSV file
df = pd.read_csv(file_path)
print("✅ CSV Columns Detected:", df.columns.tolist())

# Define expected columns (case-sensitive to match CSV)
required_columns = [
    'row_id', 'Name', 'Description', 'Address',
    'Google_Marker', 'image_link', 'logo_link', 'Open_hours',
    'Happy_hour_start', 'Happy_hour_end', 'Happy_hours_yes_no',
    'Telephone', 'Remark'
]

# Warn if any expected columns are missing
missing = [col for col in required_columns if col not in df.columns]
if missing:
    print(f"⚠️ WARNING: Missing expected columns in CSV: {missing}")
else:
    print("✅ All expected columns are present.")

# DB connection
connection = pymysql.connect(
    host='mysql2-p2.ezhostingserver.com',
    user='sanjay',
    password='BU@R9gr2971{',
    database='interview_helper',
    charset='utf8mb4',
    cursorclass=pymysql.cursors.Cursor
)

try:
    with connection.cursor() as cursor:
        for index, row in df.iterrows():
            if index < 3:
                print(f"🔍 Row {index} Preview:", row.to_dict())

            sql = """
                INSERT INTO happy_hours_bangkok (
                    happy_hours_id, row_id, name, description, address,
                    google_marker, image_link, logo_link, open_hours,
                    happy_hour_start, happy_hour_end, happy_hours_yes_no,
                    telephone, remark
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            values = (
                str(uuid.uuid4()),
                clean(row['row_id']),
                clean(row['Name']),
                clean(row['Description']),
                clean(row['Address']),
                clean(row['Google_Marker']),
                clean(row['image_link']),
                clean(row['logo_link']),
                clean(row['Open_hours']),
                clean(row['Happy_hour_start']),
                clean(row['Happy_hour_end']),
                clean(row['Happy_hours_yes_no']),
                clean(row['Telephone']),
                clean(row['Remark'])
            )
            cursor.execute(sql, values)

        connection.commit()
        print("✅ Data inserted successfully.")

except Exception as e:
    print("❌ Error:", e)

finally:
    connection.close()
