import json
import sqlite3
import urllib.request
import os

OUI_URL = "https://raw.githubusercontent.com/silverwind/oui-data/master/index.json"
OUTPUT_DIR = "assets/data"
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "oui.db")

def main():
    print(f"Fetching OUI data from {OUI_URL}...")
    try:
        with urllib.request.urlopen(OUI_URL) as response:
            data = json.loads(response.read().decode())
    except Exception as e:
        print(f"Error fetching data: {e}")
        return

    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)

    if os.path.exists(OUTPUT_FILE):
        os.remove(OUTPUT_FILE)

    print(f"Creating SQLite database at {OUTPUT_FILE}...")
    conn = sqlite3.connect(OUTPUT_FILE)
    cursor = conn.cursor()

    # Create table with prefix as primary key for ultra-fast lookup
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS oui (
            prefix TEXT PRIMARY KEY,
            vendor TEXT NOT NULL
        )
    """)

    # Prepare data for insertion (OUI prefixes in silverwind/oui-data are usually 6 chars)
    # The format is {"000000": "XEROX CORPORATION", ...}
    insert_data = []
    for prefix, vendor in data.items():
        # Normalize prefix to XX:XX:XX format for consistency with our Dart code
        if len(prefix) == 6:
            formatted_prefix = f"{prefix[0:2]}:{prefix[2:4]}:{prefix[4:6]}".upper()
            insert_data.append((formatted_prefix, vendor))

    print(f"Inserting {len(insert_data)} records...")
    cursor.executemany("INSERT INTO oui (prefix, vendor) VALUES (?, ?)", insert_data)
    
    conn.commit()
    conn.close()
    print("OUI database generation complete!")

if __name__ == "__main__":
    main()
