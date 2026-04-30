"""
load_to_sqlite.py
Load the Cookie Cats CSV into a SQLite database.
This simulates loading data from CSV into a real warehouse.
"""

import sqlite3
import pandas as pd
import os

# Where the CSV lives and where the database will be created
CSV_PATH = "data/raw/cookie_cats.csv"
DB_PATH = "data/cookie_cats.db"


def main():
    # If a database already exists from a previous run, delete it
    # This way we always start fresh
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)
        print(f"Removed old database at {DB_PATH}")

    # Read the CSV into a pandas DataFrame
    print(f"Reading CSV from {CSV_PATH}...")
    df = pd.read_csv(CSV_PATH)
    print(f"Loaded {len(df):,} rows")

    # Connect to SQLite (creates the file if it doesn't exist)
    conn = sqlite3.connect(DB_PATH)

    # Write the dataframe to a table called 'experiment_data'
    df.to_sql("experiment_data", conn, if_exists="replace", index=False)
    print(f"Wrote {len(df):,} rows to table 'experiment_data'")

    # Add an index on userid - speeds up queries that filter by user
    cursor = conn.cursor()
    cursor.execute("CREATE INDEX idx_userid ON experiment_data(userid)")
    conn.commit()
    print("Created index on userid")

    # Quick verification - count rows in the database
    cursor.execute("SELECT COUNT(*) FROM experiment_data")
    count = cursor.fetchone()[0]
    print(f"\nVerification: database contains {count:,} rows")

    conn.close()
    print(f"\nDone. Database saved to {DB_PATH}")


if __name__ == "__main__":
    main()