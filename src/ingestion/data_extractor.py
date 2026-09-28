import zipfile
from pathlib import Path

import requests


def download_gtfs():

    Path("data/raw").mkdir(
        parents=True, exist_ok=True
    )  # Create the directory if it doesn't exist

    url = "https://gtfs.tpbi.ro/regional/BUCHAREST-REGION.zip"  # URL of the GTFS data

    try:
        response = requests.get(
            url, timeout=30
        )  # Make a GET request to the URL with a timeout of 30 seconds
        response.raise_for_status()

        with open(
            "data/raw/gtfs.zip", "wb"
        ) as file:  # Open the file in binary write mode
            file.write(response.content)
        return True

    except (
        requests.exceptions.RequestException
    ) as error:  # Handle any exceptions that occur during the request
        print(f"Failed to download GTFS: {error}")
        return False


def extract_gtfs():
    try:
        with zipfile.ZipFile(
            "data/raw/gtfs.zip", "r"
        ) as zip_ref:  # Open the downloaded zip file
            zip_ref.extractall(
                "data/raw/gtfs"
            )  # Extract the contents to the specified directory

    except (
        zipfile.BadZipFile
    ) as error:  # Handle any exceptions that occur during extraction
        print(f"Failed to extract GTFS: {error}")


def main():
    if (
        download_gtfs()
    ):  # Call the download_gtfs function and check if it was successful
        extract_gtfs()  # Call the extract_gtfs function if the download was successful


if __name__ == "__main__":
    main()  # Call the main function if the script is run directlyv
