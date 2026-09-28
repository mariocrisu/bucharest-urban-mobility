import csv
import hashlib
import os

import psycopg
from dotenv import load_dotenv

load_dotenv()

GTFS_TABLES = {
    "agency": {
        "file": "data/raw/gtfs/agency.txt",
        "columns": [
            "agency_id",
            "agency_name",
            "agency_url",
            "agency_timezone",
            "agency_lang",
            "agency_phone",
            "agency_fare_url",
            "agency_email",
        ],
    },
    "stops": {
        "file": "data/raw/gtfs/stops.txt",
        "columns": [
            "stop_id",
            "stop_name",
            "stop_desc",
            "stop_lat",
            "stop_lon",
            "location_type",
            "platform_code",
            "parent_station",
            "level_id",
        ],
    },
}


def calculate_file_hash(file_path):
    """Calculate the SHA-256 hash of a file."""
    hasher = hashlib.sha256()

    with open(file_path, "rb") as file:
        for chunk in iter(lambda: file.read(4096), b""):
            hasher.update(chunk)

    return hasher.hexdigest()


def connect_to_db():
    """Connect to the PostgreSQL database."""
    try:
        connection = psycopg.connect(
            host="localhost",
            port=5432,
            dbname=os.getenv("POSTGRES_DB"),
            user=os.getenv("POSTGRES_USER"),
            password=os.getenv("POSTGRES_PASSWORD"),
        )
        return connection

    except psycopg.OperationalError as error:
        print(f"Failed to connect to the database: {error}")
        return None


def batch_exists(connection, file_hash):
    """Check whether a GTFS file has already been ingested."""
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT batch_id
            FROM raw.ingestion_batches
            WHERE file_hash = %s
            """,
            (file_hash,),
        )

        result = cursor.fetchone()

    return result is not None


def create_batch(connection, source, file_hash):
    """Create a new ingestion batch and return its ID."""
    with connection.cursor() as cursor:
        cursor.execute(
            """
            INSERT INTO raw.ingestion_batches (source, file_hash)
            VALUES (%s, %s)
            RETURNING batch_id
            """,
            (source, file_hash),
        )

        result = cursor.fetchone()

    return result[0]


def load_gtfs_file(connection, batch_id, file_path, table_name, columns):
    """Load a GTFS file into its corresponding raw table."""
    with open(file_path, "r", encoding="utf-8-sig", newline="") as file:
        reader = csv.DictReader(file)

        column_list = ", ".join(["batch_id"] + columns)

        copy_query = f"""
            COPY raw.{table_name} ({column_list})
            FROM STDIN
        """

        with connection.cursor() as cursor, cursor.copy(copy_query) as copy:
            for row in reader:
                values = [batch_id] + [row[column] for column in columns]
                copy.write_row(values)


def main():
    gtfs_zip_path = "data/raw/gtfs.zip"
    source = "TPBI_GTFS_STATIC"

    file_hash = calculate_file_hash(gtfs_zip_path)
    print(f"GTFS file hash: {file_hash}")

    connection = connect_to_db()

    if connection:
        with connection:
            if batch_exists(connection, file_hash):
                print("This GTFS batch has already been ingested.")
                return

            batch_id = create_batch(connection, source, file_hash)

            for table_name, config in GTFS_TABLES.items():
                load_gtfs_file(
                    connection=connection,
                    batch_id=batch_id,
                    file_path=config["file"],
                    table_name=table_name,
                    columns=config["columns"],
                )

            print(f"GTFS batch {batch_id} successfully ingested.")

    else:
        print("Failed to connect to the database.")


if __name__ == "__main__":
    main()
