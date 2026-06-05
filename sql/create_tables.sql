-- Database schema for the football XAI performance analysis project
-- This schema is designed for football event data parsed from Wyscout JSON files.

CREATE TABLE IF NOT EXISTS matches (
    match_id INTEGER PRIMARY KEY,
    competition_id INTEGER,
    season_id INTEGER,
    match_date TEXT,
    home_team_id INTEGER,
    away_team_id INTEGER,
    home_score INTEGER,
    away_score INTEGER
);

CREATE TABLE IF NOT EXISTS teams (
    team_id INTEGER PRIMARY KEY,
    team_name TEXT,
    competition_id INTEGER
);

CREATE TABLE IF NOT EXISTS players (
    player_id INTEGER PRIMARY KEY,
    player_name TEXT,
    team_id INTEGER,
    role TEXT
);

CREATE TABLE IF NOT EXISTS events (
    event_id INTEGER PRIMARY KEY,
    match_id INTEGER,
    team_id INTEGER,
    player_id INTEGER,
    event_name TEXT,
    sub_event_name TEXT,
    period TEXT,
    event_time REAL,
    start_x REAL,
    start_y REAL,
    end_x REAL,
    end_y REAL,
    FOREIGN KEY (match_id) REFERENCES matches(match_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    FOREIGN KEY (player_id) REFERENCES players(player_id)
);
