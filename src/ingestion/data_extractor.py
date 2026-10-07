import zipfile
from pathlib import Path

import requests

GTFS_URL = "https://gtfs.tpbi.ro/regional/BUCHAREST-REGION.zip"
RAW_DIR = Path("data/raw")
ZIP_PATH = RAW_DIR / "gtfs.zip"
EXTRACT_PATH = RAW_DIR / "gtfs"


def download_gtfs():
    RAW_DIR.mkdir(parents=True, exist_ok=True)

    try:
        response = requests.get(GTFS_URL, timeout=30)
        response.raise_for_status()

        ZIP_PATH.write_bytes(response.content)
        return True

    except requests.exceptions.RequestException as error:
        print(f"Failed to download GTFS: {error}")
        return False


def extract_gtfs():
    try:
        with zipfile.ZipFile(ZIP_PATH, "r") as zip_ref:
            zip_ref.extractall(EXTRACT_PATH)

    except zipfile.BadZipFile as error:
        print(f"Failed to extract GTFS: {error}")


def main():
    if download_gtfs():
        extract_gtfs()
        print(f"GTFS extracted to {EXTRACT_PATH}")


if __name__ == "__main__":
    main()
