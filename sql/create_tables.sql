-- Database schema for the football XAI performance analysis project
-- Designed based on the Wyscout event data structure and the project SQL pipeline.

CREATE TABLE IF NOT EXISTS matches (
    matchId INTEGER PRIMARY KEY,
    competitionId INTEGER,
    seasonId INTEGER,
    gameweek INTEGER,
    dateutc TEXT,
    label TEXT,
    winner INTEGER,
    venue TEXT
);

CREATE TABLE IF NOT EXISTS teams (
    teamId INTEGER PRIMARY KEY,
    name TEXT,
    officialName TEXT,
    city TEXT,
    type TEXT
);

CREATE TABLE IF NOT EXISTS players (
    playerId INTEGER PRIMARY KEY,
    firstName TEXT,
    lastName TEXT,
    shortName TEXT,
    role TEXT,
    birthDate TEXT,
    foot TEXT,
    height INTEGER,
    weight INTEGER
);

CREATE TABLE IF NOT EXISTS match_teams (
    matchId INTEGER,
    teamId INTEGER,
    side TEXT,
    score INTEGER,
    PRIMARY KEY (matchId, teamId),
    FOREIGN KEY (matchId) REFERENCES matches(matchId),
    FOREIGN KEY (teamId) REFERENCES teams(teamId)
);

CREATE TABLE IF NOT EXISTS events (
    eventId INTEGER PRIMARY KEY,
    matchId INTEGER,
    teamId INTEGER,
    playerId INTEGER,
    eventName TEXT,
    subEventName TEXT,
    period TEXT,
    eventSec REAL,
    FOREIGN KEY (matchId) REFERENCES matches(matchId),
    FOREIGN KEY (teamId) REFERENCES teams(teamId),
    FOREIGN KEY (playerId) REFERENCES players(playerId)
);

CREATE TABLE IF NOT EXISTS event_positions (
    eventId INTEGER,
    posOrder INTEGER,
    x REAL,
    y REAL,
    PRIMARY KEY (eventId, posOrder),
    FOREIGN KEY (eventId) REFERENCES events(eventId)
);

CREATE TABLE IF NOT EXISTS lineup (
    matchId INTEGER,
    teamId INTEGER,
    playerId INTEGER,
    goals INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    ownGoals INTEGER DEFAULT 0,
    yellowCards INTEGER DEFAULT 0,
    redCards INTEGER DEFAULT 0,
    FOREIGN KEY (matchId) REFERENCES matches(matchId),
    FOREIGN KEY (teamId) REFERENCES teams(teamId),
    FOREIGN KEY (playerId) REFERENCES players(playerId)
);

CREATE TABLE IF NOT EXISTS bench (
    matchId INTEGER,
    teamId INTEGER,
    playerId INTEGER,
    goals INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    ownGoals INTEGER DEFAULT 0,
    yellowCards INTEGER DEFAULT 0,
    redCards INTEGER DEFAULT 0,
    FOREIGN KEY (matchId) REFERENCES matches(matchId),
    FOREIGN KEY (teamId) REFERENCES teams(teamId),
    FOREIGN KEY (playerId) REFERENCES players(playerId)
);
