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
GROUP BY teams.team_id
HAVING teams.season = 2020 -- need to use HAVING instead of WHERE, if we have a GROUP BY in the query
ORDER BY 
	"for" DESC,
	team_name ASC; -- order by "for" column descending, then by ascending team_name if there's a tie
