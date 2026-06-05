"}
# Data

This folder is used to organize the data for the football XAI performance analysis project.

## Data Source

The project uses a comprehensive soccer event dataset based on Wyscout event data:

Dataset: Wyscout Soccer Match Event Dataset  
Source: https://github.com/koenvo/wyscout-soccer-match-event-dataset

The dataset contains detailed soccer match event data, including passes, shots, duels, fouls, interceptions, and other on-ball actions. These events are used to construct tactical and performance-related features for explainable machine learning analysis.

## Project Objective

The proposed project focuses on analyzing soccer event data to identify meaningful tactical patterns and performance parameters by means of Explainable Artificial Intelligence algorithms.

The dataset is used to support the full analytical pipeline, including:

- JSON data parsing
- SQLite database construction
- Match-level and team-level feature extraction
- Tactical indicators such as PPDA and Expected Goals
- Zone-based spatial features
- Explainable machine learning analysis

## Expected Folder Structure

text data/ ├── raw/ │   └── Original JSON files from the Wyscout soccer match event dataset │ └── processed/     └── Processed CSV files generated from the feature engineering pipeline 

## Raw Data

Place the original JSON files inside:

text data/raw/ 

Example files may include:

text events_England.json events_Italy.json events_Spain.json matches_England.json teams.json players.json 

## Processed Data

Processed datasets generated from the feature engineering pipeline should be saved inside:

text data/processed/ 

For example:

text per_match_features.csv 

## Note

The raw dataset, generated SQLite database files, and processed CSV files are not included in this repository because they may be large. Users should download the dataset separately from the original GitHub repository and place the files in the correct folder
