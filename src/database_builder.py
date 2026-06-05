"""
Database builder module for the football XAI performance analysis project.

This script creates a SQLite database using the schema defined in
sql/create_tables.sql.
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
    database_path.parent.mkdir(parents=True, exist_ok=True)

    connection = sqlite3.connect(database_path)
    return connection


def execute_sql_script(connection, sql_file_path):
    """
    Execute a SQL script file.

    Parameters
    ----------
    connection : sqlite3.Connection
        SQLite database connection.
    sql_file_path : str
        Path to the SQL script file.
    """
    sql_file_path = Path(sql_file_path)

    if not sql_file_path.exists():
        raise FileNotFoundError(f"SQL file not found: {sql_file_path}")

    with open(sql_file_path, "r", encoding="utf-8") as file:
        sql_script = file.read()

    connection.executescript(sql_script)
    connection.commit()


def build_database(database_path="database/football_analytics.db",
                   schema_path="sql/create_tables.sql"):
    """
    Build the SQLite database using the project schema.
    """
    connection = create_connection(database_path)

    try:
        execute_sql_script(connection, schema_path)
        print(f"Database created successfully: {database_path}")
    finally:
        connection.close()


if __name__ == "__main__":
    build_database()
