"""
Data parsing module for the football XAI performance analysis project.

This module provides helper functions for loading Wyscout JSON files and
preparing event and position data for database insertion.
"""

import json
from pathlib import Path
import pandas as pd


def load_json_file(file_path):
    """
    Load a JSON file from the given path.

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
        return json.load(file)


def events_to_dataframe(events):
    """
    Convert Wyscout event JSON data into an events DataFrame.

    Expected Wyscout fields include:
    eventId, matchId, teamId, playerId, eventName, subEventName,
    matchPeriod, eventSec.
    """
    rows = []

    for event in events:
        rows.append({
            "eventId": event.get("id") or event.get("eventId"),
            "matchId": event.get("matchId"),
            "teamId": event.get("teamId"),
            "playerId": event.get("playerId"),
            "eventName": event.get("eventName"),
            "subEventName": event.get("subEventName"),
            "period": event.get("matchPeriod"),
            "eventSec": event.get("eventSec")
        })

    return pd.DataFrame(rows)


def event_positions_to_dataframe(events):
    """
    Convert event positions into a separate DataFrame.

    Each event can contain one or two positions:
    posOrder = 0 for start position
    posOrder = 1 for end position
    """
    rows = []

    for event in events:
        event_id = event.get("id") or event.get("eventId")
        positions = event.get("positions", [])

        for pos_order, position in enumerate(positions):
            rows.append({
                "eventId": event_id,
                "posOrder": pos_order,
                "x": position.get("x"),
                "y": position.get("y")
            })

    return pd.DataFrame(rows)


if __name__ == "__main__":
    print("Data parsing module is ready.")
