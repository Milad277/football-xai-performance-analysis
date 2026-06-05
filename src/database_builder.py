"""
Database builder module for the football analytics project.

This script provides the initial structure for creating and connecting to
a SQLite database that will store parsed football event data.
"""

import sqlite3
from pathlib import Path


def create_connection(database_path):
    """
    Create a connection to a SQLite database.

    Parameters
    ----------
    database_path : str
        Path to the SQLite database file.

    Returns
    -------
    sqlite3.Connection
        SQLite database connection object.
    """
    database_path = Path(database_path)

    # Create parent folder if it does not exist
    database_path.parent.mkdir(parents=True, exist_ok=True)

    connection = sqlite3.connect(database_path)
    return connection


def close_connection(connection):
    """
    Close the SQLite database connection.

    Parameters
    ----------
    connection : sqlite3.Connection
        SQLite database connection object.
    """
    if connection:
        connection.close()


if __name__ == "__main__":
    db_path = "database/football_analytics.db"

    conn = create_connection(db_path)
    print(f"Database connection created successfully: {db_path}")

    close_connection(conn)
    print("Database connection closed.")
