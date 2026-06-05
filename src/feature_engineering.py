"""
Feature engineering module for the football XAI performance analysis project.

The main feature engineering pipeline is based on SQL queries that aggregate
football event data into match-level and team-level tactical features.

This module provides helper functions to run SQL feature queries and export
the resulting dataset.
"""

import sqlite3
from pathlib import Path
import pandas as pd


def run_sql_query(database_path, query_path):
    """
    Run a SQL query file on a SQLite database and return the result as a DataFrame.

    Parameters
    ----------
    database_path : str
        Path to the SQLite database.
    query_path : str
        Path to the SQL query file.

    Returns
    -------
    pandas.DataFrame
        Query result.
    """
    database_path = Path(database_path)
    query_path = Path(query_path)

    if not database_path.exists():
        raise FileNotFoundError(f"Database not found: {database_path}")

    if not query_path.exists():
        raise FileNotFoundError(f"SQL query file not found: {query_path}")

    with open(query_path, "r", encoding="utf-8") as file:
        query = file.read()

    with sqlite3.connect(database_path) as connection:
        df = pd.read_sql_query(query, connection)

    return df


def export_features_to_csv(database_path,
                           query_path,
                           output_path="data/processed/per_match_features.csv"):
    """
    Run the feature extraction query and export the result to CSV.
    """
    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    features_df = run_sql_query(database_path, query_path)
    features_df.to_csv(output_path, index=False)

    print(f"Features exported successfully: {output_path}")
    return features_df


if __name__ == "__main__":
    DATABASE_PATH = "database/football_analytics.db"
    QUERY_PATH = "sql/final_features.sql"
    OUTPUT_PATH = "data/processed/per_match_features.csv"

    export_features_to_csv(DATABASE_PATH, QUERY_PATH, OUTPUT_PATH)
