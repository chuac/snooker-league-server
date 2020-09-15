-- https://www.postgresql.org/docs/8.1sql-keywords-appendix.html

--\c snooker_league -- connect to snooker_league database

DROP TABLE IF EXISTS players, locations, teams, players_in_teams, matches, frames; -- drop "old" tables to create fresh ones again

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
	season INTEGER NOT NULL, -- for which year/season does this team belong to?
    FOREIGN KEY (home_id)
        REFERENCES locations (location_id)
);

-- this table links players to corresponding teams (one player to many teams, over many seasons)
-- each team may have a varying amount of players for them each season so this approach of a third table to relate them together makes more sense
-- (compared to one "players" column inside each team's row that has a string you'd have to parse every time you want to access it)
CREATE TABLE players_in_teams (
    player_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    PRIMARY KEY (player_id, team_id), -- force the combination of (player_id, team_id) to be unique and the primary key for this table
    FOREIGN KEY (player_id)
        REFERENCES players (player_id),
    FOREIGN KEY (team_id)
        REFERENCES teams (team_id)
);

-- CREATE TABLE years ( -- do we need a years table? why not just reference a year in each relation?
-- 	year INTEGER PRIMARY KEY,
-- 	team_id
-- )

-- Jens: yeah, that makes sense, the api endpoint should still be /2000/:team/ though I'm guessing?
-- Chris: yeah the endpoint should be like /:year/teams (like /2020/teams) or /:year/team/:id (like /2020/team/3)

CREATE TABLE matches (
	match_id SERIAL PRIMARY KEY,
	match_date DATE NOT NULL, -- Postgres stores DATE in yyyy-mm-dd format
    season INTEGER NOT NULL, -- this column may not be required since we can get season from the home or away team's data
    week SMALLINT NOT NULL, -- in which # week in the season was this match held
	home_team_id INTEGER NOT NULL,
	away_team_id INTEGER NOT NULL,
    home_team_score SMALLINT, -- thinking of pre-computing their scores instead of counting frames (Win or Loss) every time we need this data
    away_team_score SMALLINT,
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

INSERT INTO teams (team_name, home_id, season)
VALUES
	('Jokers', 2, 2020),
	('Cannington Ones', 1, 2020),
	('Baby Sharks', 1, 2020),
	('Breakers', 3, 2020);

INSERT INTO players_in_teams (player_id, team_id)
VALUES
    (1, 1),
    (2, 1), -- player with ID of 2 belongs to team with ID of 1
    (3, 1),
    (4, 1),
    (5, 2),
    (6, 2),
    (7, 2),
    (8, 2),
    (9, 3),
    (10, 3),
    (11, 3),
    (12, 3),
    (13, 4),
    (14, 4),
    (15, 4),
    (16, 4);

INSERT INTO matches (match_date, season, week, home_team_id, away_team_id, home_team_score, away_team_score)
VALUES
	('2020-09-14', 2020, 1, 1, 4, 7, 5), -- Jokers home team, Breakers away team
	('2020-09-14', 2020, 1, 2, 3, 3, 9), -- Cannington Ones home team, Baby Sharks away team
	('2020-09-21', 2020, 2, 1, 3, 10, 2), -- TEST MATCH TO TEST QUERIES. NO CORRESPONDING FRAMES FOR THIS MATCH
	('2020-09-21', 2020, 2, 2, 4, 4, 8); -- TEST MATCH TO TEST QUERIES. NO CORRESPONDING FRAMES FOR THIS MATCH

INSERT INTO frames (match_id, player_one_id, player_two_id, player_one_broke, player_one_score, player_two_score, player_one_break, player_two_break)
VALUES
	(1, 1, 5, true, 50, 49, 0, 0),
	(1, 1, 8, false, 33, 65, 0, 60),
	(1, 1, 7, true, 49, 35, 23, 0),
	(1, 2, 5, false, 85, 0, 85, 0),
	(1, 2, 6, true, 39, 55, 25, 0),
	(1, 2, 8, false, 99, 23, 60, 23),
	(1, 3, 5, true, 11, 97, 0, 85),
	(1, 3, 6, false, 66, 65, 55, 0),
	(1, 3, 7, true, 30, 46, 0, 0),
	(1, 4, 6, false, 29, 36, 0, 0),
	(1, 4, 7, false, 147, 0, 147, 0),
	(1, 4, 8, true, 59, 19, 40, 0),
	
	(2, 9, 13, true, 19, 89, 0, 43),
	(2, 9, 16, false, 55, 15, 0, 0),
	(2, 9, 15, true, 59, 44, 24, 0),
	(2, 10, 13, false, 1, 100, 0, 100),
	(2, 10, 14, true, 9, 85, 0, 79),
	(2, 10, 16, false, 65, 43, 0, 0),
	(2, 11, 13, true, 13, 85, 0, 85),
	(2, 11, 14, false, 26, 47, 0, 0),
	(2, 11, 15, true, 25, 91, 0, 70),
	(2, 12, 14, false, 28, 48, 0, 0),
	(2, 12, 15, false, 0, 141, 0, 141),
	(2, 12, 16, true, 11, 88, 0, 88);









