
# Database

This folder is used for the SQLite database generated during the football XAI performance analysis project.

## SQLite Database

The project uses a SQLite database to store structured football event data parsed from the original Wyscout soccer match event dataset.

The database is created from the schema defined in:

text sql/create_tables.sql 

The expected generated database file is:

text database/football_analytics.db 

## Why the Database File Is Not Included

The generated SQLite database file is not included in this repository because database files can be large and are generated outputs.

Instead of committing the database file to GitHub, users should recreate it locally using the source code and SQL schema provided in the repository.

## How to Recreate the Database

To recreate the SQLite database, users should:

1. Download the raw Wyscout soccer match event dataset.
2. Place the JSON files inside:

text data/raw/ 

3. Use the Python scripts in the src/ folder to parse the JSON files and prepare structured tables.
4. Create the SQLite database using:

text src/database_builder.py 

5. Use the SQL scripts in the sql/ folder to extract the final machine-learning-ready features.

## Expected Workflow

text Raw Wyscout JSON files ↓ Python parsing scripts ↓ SQLite database creation ↓ SQL feature extraction ↓ Processed feature dataset ↓ Machine learning and XAI analysis 

## Notes

Do not commit generated database files such as:

text *.db *.sqlite *.sqlite3 

These files should remain local and are ignored using the `.gitignore
