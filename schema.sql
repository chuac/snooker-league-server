-- https://www.postgresql.org/docs/8.1sql-keywords-appendix.html

--\c snooker_league -- connect to snooker_league database

DROP TABLE IF EXISTS players, teams, locations, matches, frames; -- drop "old" tables to create fresh ones again

CREATE TABLE players (
    player_id SERIAL PRIMARY KEY,
    player_name VARCHAR (255) UNIQUE NOT NULL, -- cannot have duplicate player names
    created_on TIMESTAMP DEFAULT NOW()
);

CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    location_name VARCHAR (255) NOT NULL,
    abbreviation VARCHAR (10)
);

CREATE TABLE teams (
	team_id SERIAL PRIMARY KEY,
	team_name VARCHAR (255) NOT NULL,
    home_id INTEGER NOT NULL, -- home location (id) for this team
	year INT NOT NULL, -- for which year/season does this team belong to?
    FOREIGN KEY (home_id)
        REFERENCES locations (location_id)
);

-- CREATE TABLE years ( -- do we need a years table? why not just reference a year in each relation?
-- 	year INTEGER PRIMARY KEY,
-- 	team_id
-- )

CREATE TABLE matches (
	match_id SERIAL PRIMARY KEY,
	match_date DATE NOT NULL, -- Postgres stores DATE in yyyy-mm-dd format
	home_team_id INTEGER NOT NULL,
	away_team_id INTEGER NOT NULL,
	FOREIGN KEY (home_team_id)
		REFERENCES teams (team_id),
	FOREIGN KEY (away_team_id)
		REFERENCES teams (team_id)
);

CREATE TABLE frames (
	frame_id SERIAL PRIMARY KEY,
	match_id INTEGER NOT NULL, -- which match (id) this frame belongs to
	player_one_id INTEGER NOT NULL,
	player_two_id INTEGER NOT NULL,
	player_one_broke BOOLEAN, -- true or false depending on which player broke off the frame (first turn in Snooker)
	player_one_score SMALLINT, -- final score for player one
	player_two_score SMALLINT, -- final score for player two
	player_one_break SMALLINT, -- highest break for player one in this frame
	player_two_break SMALLINT, -- highest break for player two in this frame
	FOREIGN KEY (match_id)
		REFERENCES matches (match_id),
	FOREIGN KEY (player_one_id)
		REFERENCES players (player_id),
	FOREIGN KEY (player_two_id)
		REFERENCES players (player_id)
);

-- Start of dummy data
INSERT INTO players (player_name)
VALUES
	('Christopher Chua'),
	('Jens Adria'),
	('Neil Robertson'),
	('Judd Trump'),
	('Ronnie O''Sullivan'), -- extra quotation mark to escape single quote in player's name
	('Mark Selby'),
	('Ding Junhui'),
	('Mark J Williams'),
	('Kyren Wilson'),
	('Thepchaiya Un-Nooh'),
	('John Higgins'),
	('Stephen Hendry'),
	('Marco Fu'),
	('Jack Lisowski'),
	('Mark Allen'),
	('Shaun Murphy');
	

INSERT INTO locations (location_name, abbreviation)
VALUES
	('Cannington', 'C'),
	('Northbridge', 'NB'),
	('North Perth', 'NP');

INSERT INTO teams (team_name, home_id, year)
VALUES
	('Jokers', 2, 2020),
	('Cannington Ones', 1, 2020),
	('Baby Sharks', 1, 2020),
	('Breakers', 3, 2020);

INSERT INTO matches (match_date, home_team_id, away_team_id)
VALUES
	('2020-09-14', 1, 4), -- Jokers home team, Breakers away team
	('2020-09-14', 2, 3); -- Cannington Ones home team, Baby Sharks away team










