-- Scratchpad for SQL queries

-- return all matches in 2020 with match dates, seasons, weeks, location names, the home team and the away teams' names
SELECT 
	matches.match_date, 
	matches.season, 
	matches.week, 
	locations.location_name, 
	home.team_name AS home_team, 
	away.team_name AS away_team
FROM matches
INNER JOIN teams AS home
	ON matches.home_team_id = home.team_id 
INNER JOIN teams AS away
	ON matches.away_team_id = away.team_id 
INNER JOIN locations
	ON home.home_id = locations.location_id 
WHERE matches.season = '2020';

-- return all frames in 2020 with home & away players (and their team names), their respective scores, and whether or not the home player won that frame
SELECT
	home.team_name AS home_team_name,
	home_player.player_name AS home_player_name,
	frames.player_one_score AS home_player_score,
	away.team_name AS away_team_name,
	away_player.player_name AS away_player_name,
	frames.player_two_score AS away_player_score,
	CASE
		WHEN frames.player_one_score > frames.player_two_score THEN true
		ELSE false
	END AS home_player_won
FROM frames
INNER JOIN matches
	ON frames.match_id = matches.match_id
INNER JOIN teams AS home
	ON matches.home_team_id = home.team_id 
INNER JOIN teams AS away
	ON matches.away_team_id = away.team_id
INNER JOIN players AS home_player
	ON frames.player_one_id = home_player.player_id
INNER JOIN players AS away_player
	ON frames.player_two_id = away_player.player_id
WHERE matches.season = 2020;

-- returns league table for that year, with for and against frames
-- since we don't want to pre-compute each team's for & against, in case we want to view the table in the "past"
SELECT
	team_name,
	COALESCE(SUM(home.home_team_score), 0) + COALESCE(SUM(away.away_team_score), 0) AS "for", -- COALESCE runs the first argument if it's not null, otherwise it uses the second argument (0)
	COALESCE(SUM(home.away_team_score), 0) + COALESCE(SUM(away.home_team_score), 0) AS "against" --  double quotes for these column aliases because "for" may be a SQL keyword
FROM teams
LEFT JOIN matches AS home -- left join as that particular team may not always be the home team in that match but we still want to count their score
	ON home.home_team_id = teams.team_id
LEFT JOIN matches AS away -- as stated above, if that team isn't the home team, they'd have null values so now we're looking for when they were the away team to get their data
	ON away.away_team_id = teams.team_id
WHERE teams.season = 2020
GROUP BY teams.team_id
ORDER BY 
	"for" DESC,
	team_name ASC; -- order by "for" column descending, then by ascending team_name if there's a tie

-- return UNORDERED league table at selected week ("a snapshot in the past")
SELECT
	team_name,
	COALESCE(SUM(home.home_team_score), 0) + COALESCE(SUM(away.away_team_score), 0) AS "for", -- COALESCE runs the first argument if it's not null, otherwise it uses the second argument (0)
	COALESCE(SUM(home.away_team_score), 0) + COALESCE(SUM(away.home_team_score), 0) AS "against" --  double quotes for these column aliases because "for" may be a SQL keyword
FROM teams
LEFT JOIN matches AS home -- left join as that particular team may not always be the home team in that match but we still want to count their score
	ON home.home_team_id = teams.team_id
LEFT JOIN matches AS away -- as stated above, if that team isn't the home team, they'd have null values so now we're looking for when they were the away team to get their data
	ON away.away_team_id = teams.team_id
WHERE (home.week <= 1 OR away.week <= 1) AND (teams.season = 2020)
GROUP BY teams.team_id;

-- return list of ALL the teams and ALL the seasons they participated in, in an array
SELECT team_name, ARRAY_AGG(season) AS seasons
FROM teams
GROUP BY team_name;

-- return a team (by ID) and a list of their players (remembering that team IDs are unique for that season)
SELECT
	teams.team_name,
	teams.season,
	MAX(locations.location_name) AS home_location, -- we use MAX() aggregate function here to bypass Postgres pedanticness
	ARRAY_AGG(players.player_name) AS players
FROM teams
INNER JOIN players_in_teams
	ON teams.team_id = players_in_teams.team_id
INNER JOIN players
	ON players_in_teams.player_id = players.player_id
INNER JOIN locations
	ON teams.home_id = locations.location_id
LEFT JOIN matches AS home -- left join as that particular team may not always be the home team in that match but we still want to count their score
	ON home.home_team_id = teams.team_id
LEFT JOIN matches AS away -- as stated above, if that team isn't the home team, they'd have null values so now we're looking for when they were the away team to get their data
	ON away.away_team_id = teams.team_id
WHERE teams.team_id = 1
GROUP BY teams.team_id;

-- given a team ID, return that team's overall score (for and against)
SELECT
	teams.team_name,
	COALESCE(SUM(home.home_team_score), 0) + COALESCE(SUM(away.away_team_score), 0) AS "for", -- COALESCE runs the first argument if it's not null, otherwise it uses the second argument (0)
	COALESCE(SUM(home.away_team_score), 0) + COALESCE(SUM(away.home_team_score), 0) AS "against"
FROM teams
LEFT JOIN matches AS home
	ON home.home_team_id = teams.team_id
LEFT JOIN matches AS away
	ON away.away_team_id = teams.team_id
WHERE teams.team_id = 1
GROUP BY teams.team_id;

-- return players & their data for a particular season. currently not working
SELECT
	players.player_name,
	SUM(CASE
		WHEN home.player_one_score > home.player_two_score THEN 1
		WHEN away.player_two_score > away.player_one_score THEN 1
		ELSE 0
	END) AS frames_won,
	SUM(CASE
		WHEN home.player_one_score < home.player_two_score THEN 1
		WHEN away.player_two_score < away.player_one_score THEN 1
		ELSE 0
	END) AS frames_lost
FROM players
LEFT JOIN frames AS home
	ON players.player_id = home.player_one_id
LEFT JOIN frames AS away
	ON players.player_id = away.player_two_id
INNER JOIN matches as home_matches
	ON home.match_id = home_matches.match_id
INNER JOIN matches as away_matches
	ON away.match_id = away_matches.match_id
WHERE (away_matches.season = 2020)
GROUP BY players.player_id;

-- small subquery to return frames only in a specific season. used this subquery below
(SELECT frames.*
FROM matches
INNER JOIN frames
	ON matches.match_id = frames.match_id
WHERE matches.season = 2020);

-- return players & their data for a particular season
SELECT
	players.player_name,
	SUM(CASE
		WHEN home.player_one_score > home.player_two_score THEN 1
		WHEN away.player_two_score > away.player_one_score THEN 1
		ELSE 0
	END) AS frames_won,
	SUM(CASE
		WHEN home.player_one_score < home.player_two_score THEN 1
		WHEN away.player_two_score < away.player_one_score THEN 1
		ELSE 0
	END) AS frames_lost
FROM players
LEFT JOIN 
	(SELECT frames.*
	FROM matches
	INNER JOIN frames
		ON matches.match_id = frames.match_id
	WHERE matches.season = 2020) AS home
	ON players.player_id = home.player_one_id
LEFT JOIN
	(SELECT frames.*
	FROM matches
	INNER JOIN frames
		ON matches.match_id = frames.match_id
	WHERE matches.season = 2020) AS away
	ON players.player_id = away.player_two_id
GROUP BY players.player_id;


