# SQL Queries

This folder contains the SQL scripts used in the football XAI performance analysis project.

The SQL files are used to create the SQLite database schema and extract match-level and team-level tactical features from football event data.

## Files

### create_tables.sql

This file defines the initial SQLite database schema used in the project.

The schema includes the main relational tables required to store football event data:

- matches
- teams
- players
- match_teams
- events
- event_positions
- lineup
- bench

These tables are designed to organize Wyscout soccer match event data in a structured relational format.

### final_features.sql

This file contains the main feature extraction query used to generate the final match-level dataset.

The query creates home and away team features from the event database, including:

- match information
- home and away team statistics
- event counts
- passing features
- shooting features
- defensive actions
- assists
- zone-based tactical features
- final match result labels

The output of this query can be exported as a processed CSV file and used for machine learning and explainable AI analysis.

## Workflow

The general SQL workflow is:

```text
Raw JSON data
↓
Parsed event tables
↓
SQLite relational database
↓
SQL feature extraction
↓
Processed per-match feature dataset
↓
Machine learning and XAI analysis
