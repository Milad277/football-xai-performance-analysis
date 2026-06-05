# Figures

This folder contains the main figures used to document the football XAI performance analysis project.

The figures illustrate the key stages of the analytical workflow, including data integration, database construction, tactical feature engineering, and spatial representation of football events.

## Main Figures

### 1. JSON to Database Pipeline

**File name:** `json_to_database_pipeline.png`

This figure illustrates the initial data integration process used in the project. The raw Wyscout JSON files, including players, matches, teams, and events, are merged and transformed into a structured football database.

This figure is related to the data acquisition and integration stage of the project.

---

### 2. SQLite Database Entity Relationship Diagram

**File name:** `database_erd.png`

This figure shows the Entity Relationship Diagram (ERD) of the SQLite database used in the project.

It represents the main relational tables, such as matches, teams, players, events, event positions, lineup, and bench data. The diagram also shows the primary and foreign key relationships that allow football events to be traced back to their corresponding matches, teams, and players.

This figure supports the database construction and relational data modeling part of the project.

---

### 3. PPDA Pitch Area

**File name:** `ppda_pitch_area.png`

This figure provides a conceptual illustration of the pitch area used for calculating Passes Per Defensive Action (PPDA).

PPDA is used as a tactical indicator of pressing intensity. It measures how many opponent passes are allowed before a defensive action is made. Lower PPDA values indicate more aggressive pressing, while higher values suggest a more passive defensive approach.

This figure supports the tactical feature engineering section of the project.

---

### 4. Expected Goals Shot Map

**File name:** `xg_shot_map.png`

This figure illustrates shot locations and their corresponding Expected Goals (xG) values.

Expected Goals is used to estimate the quality of goal-scoring opportunities based on shot characteristics such as location, distance, angle, and context. In this project, xG helps distinguish between teams that create many low-quality chances and teams that generate fewer but more dangerous opportunities.

This figure supports the construction of advanced attacking features.

---

### 5. Zone-Based Pitch Division

**File name:** `zone_based_pitch.png`

This figure shows the division of the football pitch into three main tactical zones:

- Defensive third
- Middle third
- Attacking third

These zones are used to construct spatial features from football event data. Zone-based features help capture where actions occur on the pitch and make the machine learning features more interpretable for football analysis.

This figure supports the spatial feature engineering and Explainable AI parts of the project.

