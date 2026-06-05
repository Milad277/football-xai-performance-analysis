# Data

This folder is used to organize the data for the football XAI performance analysis project.

## Data Source

The project is based on open-access football event data from the Wyscout Open Data repository.

The raw dataset is not included in this repository because football event data files and SQLite databases can be large. Users should download the dataset separately and place the files in the correct folders.

## Expected Folder Structure

```text
data/
├── raw/
│   └── Wyscout JSON files
│
└── processed/
    └── Processed CSV files generated from the feature engineering pipeline
