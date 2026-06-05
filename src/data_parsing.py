
"""
Data parsing module for football event data.

This script is intended to parse raw Wyscout JSON files and transform them
into structured data that can later be stored in a SQLite database.
"""

import json
from pathlib import Path


def load_json_file(file_path):
    """
    Load a JSON file from the given file path.

    Parameters
    ----------
    file_path : str
        Path to the JSON file.

    Returns
    -------
    dict or list
        Parsed JSON content.
    """
    file_path = Path(file_path)

    if not file_path.exists():
        raise FileNotFoundError(f"File not found: {file_path}")

    with open(file_path, "r", encoding="utf-8") as file:
        data = json.load(file)

    return data


if __name__ == "__main__":
    print("Football event data parsing module is ready.")
