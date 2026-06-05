
# Source Code

This folder contains the Python source code for the football XAI performance analysis project.

The code supports the main analytical pipeline of the project, including loading Wyscout soccer event data, preparing structured event tables, creating a SQLite database, running SQL-based feature extraction, and exporting processed datasets for machine learning and Explainable Artificial Intelligence analysis.

## Files

### data_parsing.py

This module contains helper functions for loading and parsing Wyscout soccer event JSON files.

Main functions:

- load_json_file(): loads a JSON file from a given file path.
- events_to_dataframe(): converts Wyscout event JSON data into a structured events DataFrame.
- event_positions_to_dataframe(): extracts event position coordinates into a separate DataFrame.

This module helps transform raw JSON event data into tabular structures suitable for database insertion.

### database_builder.py

This module is used to create a SQLite database for the project.

It uses the database schema defined in:

text sql/create_tables.sql 

Main functions:

- create_connection(): creates a connection to a SQLite database.
- execute_sql_script(): executes a SQL script file.
- build_database(): builds the SQLite database using the project schema.

The default database path is:

text database/football_analytics.db 

The database file itself is not included in the repository because generated database files can be large.

### feature_engineering.py

This module is used to run SQL feature extraction queries on the SQLite database and export the final processed feature dataset.

Main functions:

- run_sql_query(): runs a SQL query file on the SQLite database and returns the result as a pandas DataFrame.
- export_features_to_csv(): exports the extracted features to a CSV file.

The default SQL feature extraction file is:

text sql/final_features.sql 

The default output path is:

text data/processed/per_match_features.csv 

The full processed dataset is not included in this repository because of file size limitations. A small sample dataset may be included for demonstration purposes.

## General Workflow

The Python workflow is:

text Raw Wyscout JSON files 
↓
Load and parse data with data_parsing.py 
↓
Create SQLite database with database_builder.py 
↓
Run SQL feature extraction with feature_engineering.py 
↓
Export processed per-match dataset
↓
Use the processed dataset for machine learning and XAI analysis 

## Notes

Large raw data files, SQLite database files, and full processed CSV files should not be committed to this repository.

The repository is designed to document the reproducible workflow, source code, SQL queries, notebooks, and report related to the football Explainable AI performance analysis pr
