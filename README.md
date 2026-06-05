# Football XAI Performance Analysis

Explainable AI pipeline for football analytics using Wyscout soccer event data, SQLite, SQL-based feature engineering, tactical indicators, and interpretable machine learning models.

## Project Overview

This repository contains the code, documentation, notebooks, SQL queries, figures, and report for the project:

**Explainable Artificial Intelligence in Sports Analytics**

The project focuses on applying Explainable Artificial Intelligence methods to football event data in order to analyze team structure, tactical behavior, and the importance of performance parameters.

The main objective is not only to build predictive models, but also to identify interpretable tactical patterns that can support football performance analysis.

## Dataset

The project uses the Wyscout Soccer Match Event Dataset:

**Dataset source:** https://github.com/koenvo/wyscout-soccer-match-event-dataset

The dataset contains detailed soccer match event data, including passes, shots, duels, fouls, interceptions, and other on-ball actions.

The raw data files are not included in this repository because of file size limitations. Users should download the dataset separately and place the JSON files inside:

`data/raw/`

## Project Pipeline

The complete analytical workflow includes:

1. Downloading the Wyscout soccer match event dataset
2. Parsing raw JSON files
3. Creating structured event and position tables
4. Building a SQLite relational database
5. Extracting match-level and team-level features using SQL
6. Computing tactical indicators such as PPDA and Expected Goals
7. Creating zone-based spatial features
8. Preparing the final processed dataset
9. Evaluating machine learning models
10. Applying Explainable AI methods for interpretation

## Key Features

The project includes several types of football analytics features:

- Basic event counts
- Passing features
- Shooting features
- Defensive actions
- Assists
- PPDA
- Expected Goals
- Zone-based pitch features
- Home and away team statistics
- Match result labels

## Explainable AI Approach

The project focuses on interpretable and explainable machine learning methods.

The main Explainable AI objective is to understand which tactical and performance-related variables contribute to match outcomes.

The analysis includes rule-based and interpretable modeling concepts, with particular attention to the Logic Learning Machine workflow used in the Rulex platform.

## Repository Structure

football-xai-performance-analysis/  
├── README.md  
├── LICENSE  
├── .gitignore  
├── requirements.txt  
├── report/  
│   └── Explainable-Artificial-Intelligence-in-Sports-Analytics.pdf  
├── data/  
│   ├── README.md  
│   ├── raw/  
│   └── processed/  
│       └── sample_per_match_features.csv  
├── database/  
│   └── README.md  
├── notebooks/  
│   ├── README.md  
│   ├── 01_data_exploration.ipynb  
│   ├── 02_per_match_feature_engineering.ipynb  
│   ├── 03_rulex_modeling_workflow.ipynb  
│   └── 04_results_analysis.ipynb  
├── src/  
│   ├── README.md  
│   ├── data_parsing.py  
│   ├── database_builder.py  
│   └── feature_engineering.py  
├── sql/  
│   ├── README.md  
│   ├── create_tables.sql  
│   └── final_features.sql  
└── figures/  
    ├── README.md  
    ├── json_to_database_pipeline.png  
    ├── database_erd.png  
    ├── ppda_pitch_area.png  
    ├── xg_shot_map.png  
    └── zone_based_pitch.png  

## Report

The full academic report is available in the `report/` folder.

[Read the full report](report/Explainable-Artificial-Intelligence-in-Sports-Analytics.pdf)

## Sample Data

The full processed dataset is not included because of file size limitations.

A small sample file may be included for demonstration:

`data/processed/sample_per_match_features.csv`

To reproduce the full processed dataset, users should download the raw Wyscout dataset, place the JSON files in `data/raw/`, build the SQLite database, and run the SQL feature extraction pipeline.

## Installation

Install the required Python packages using:

`pip install -r requirements.txt`

## Usage

### 1. Build the SQLite database

`python src/database_builder.py`

### 2. Run feature extraction

`python src/feature_engineering.py`

The generated processed dataset will be saved in:

`data/processed/per_match_features.csv`

## Figures

The main project figures are stored in the `figures/` folder.

They include:

- JSON to database pipeline
- SQLite database ERD
- PPDA pitch area
- Expected Goals shot map
- Zone-based pitch division

These figures help explain the project workflow, database structure, and tactical feature engineering process.

## Main Technologies

- Python
- pandas
- SQLite
- SQL
- Jupyter Notebook
- Machine Learning
- Explainable Artificial Intelligence
- Football Analytics
- Wyscout Event Data

## Author

**Milad Aghaalikhani**  
Master's in Big Data Analytics & AI for Society  


## License

This project is released under the MIT License.
