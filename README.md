# football-xai-performance-analysis
Explainable AI pipeline for football analytics using Wyscout event data, SQLite, feature engineering, PPDA, xG, and interpretable machine learning models.
# Football XAI Performance Analysis

Explainable AI pipeline for football analytics using Wyscout event data, SQLite, feature engineering, PPDA, xG, and interpretable machine learning models.

## Overview

This repository contains the code, documentation, and analytical workflow for the project **Explainable Artificial Intelligence in Sports Analytics**.

The project focuses on applying explainable machine learning techniques to football event data in order to analyse team structure, tactical behaviour, and the importance of performance parameters.

## Project Pipeline

The complete workflow includes:

1. Data acquisition from Wyscout open football event data
2. JSON parsing and data cleaning
3. Construction of a relational SQLite database
4. SQL-based feature extraction
5. Tactical feature engineering using PPDA and Expected Goals
6. Zone-based spatial feature construction
7. Machine learning model evaluation
8. Explainable AI analysis using interpretable models

## Key Concepts

- Football analytics
- Sports performance analysis
- Explainable Artificial Intelligence
- Wyscout event data
- SQLite database
- Feature engineering
- PPDA
- Expected Goals
- Zone-based tactical features
- Interpretable machine learning
- Rule-based learning

## Repository Structure

```text
football-xai-performance-analysis/
│
├── README.md
├── LICENSE
├── .gitignore
│
├── report/
│   └── Explainable-Artificial-Intelligence-in-Sports-Analytics.pdf
│
├── data/
│   ├── raw/
│   └── processed/
│
├── database/
│   └── schema.sql
│
├── notebooks/
│   ├── 01_data_exploration.ipynb
│   ├── 02_feature_engineering.ipynb
│   ├── 03_modeling.ipynb
│   └── 04_results_analysis.ipynb
│
├── src/
│   ├── data_parsing.py
│   ├── database_builder.py
│   ├── feature_engineering.py
│   ├── tactical_metrics.py
│   └── model_evaluation.py
│
├── sql/
│   ├── create_tables.sql
│   ├── extract_features.sql
│   └── ppda_features.sql
│
└── figures/
    ├── database_erd.png
    ├── ppda_pitch.png
    └── zone_based_pitch.png


Methodology

The project starts from raw football event data in JSON format and transforms it into a structured relational database. From this database, match-level and team-level features are extracted using SQL queries.

The feature engineering process combines basic statistical indicators with football-specific tactical metrics such as PPDA, Expected Goals, and zone-based spatial features. These features are then used to train and evaluate machine learning models with a focus on interpretability.

Explainable AI Approach

The main objective of the project is not only to predict football match outcomes but also to understand which tactical and performance-related factors influence the model predictions.

For this reason, the project focuses on interpretable machine learning and explainable AI techniques, allowing the results to be translated into meaningful football insights.

Author

Milad Aghaalikhani
