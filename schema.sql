--\c snooker_league -- connect to snooker_league database

DROP TABLE IF EXISTS players, teams, matches, frames; -- drop "old" tables to create fresh ones again

CREATE TABLE players (
    player_id SERIAL PRIMARY KEY,
    player_name VARCHAR (255) NOT NULL,
    created_on TIMESTAMP DEFAULT NOW()
);

CREATE TABLE teams (
	team_id SERIAL PRIMARY KEY,
	team_name VARCHAR (255) NOT NULL,
	year INT NOT NULL -- for which year/season does this team belong to?
-- 	FOREIGN KEY (year)
-- 		REFERENCES years (year)
);

-- CREATE TABLE years ( -- do we need a years table? why not just reference a year in each relation?
-- 	year INTEGER PRIMARY KEY,
-- 	team_id
-- )

CREATE TABLE matches (
	match_id SERIAL PRIMARY KEY,
	match_date DATE NOT NULL,
	home_team INTEGER NOT NULL,
	away_team INTEGER NOT NULL,
	FOREIGN KEY (home_team)
		REFERENCES teams (team_id),
	FOREIGN KEY (away_team)
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