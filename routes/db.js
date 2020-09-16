// To create a pool of connections to the PostgreSQL db. These pool of connections can then be used by other modules, simply by requiring this module!

require('dotenv').config(); // sets up .env environment variables

const { Pool } = require('pg');

const pool = new Pool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: 'snooker_league',
    port: process.env.DB_PORT || 5432 // the port specified in .env or default of 5432
});

module.exports = {
    pool: pool, // export pool to still be able to run unique queries in other files, if needed

    // PLAYERS FUNCTIONS
    getAllPlayers: async () => {
        try {
            const query = `SELECT * FROM players;`
            const { rows } = await pool.query(query); // destructuring rows array out of the pool.query() result
            console.log(rows);
            return rows;
        } catch (error) {
            console.log(error);
            return error;
        }
    },
    getOnePlayer: async (id) => { // very basic implementation for now, will be better when more dummy data available
        try {
            const query = `SELECT * FROM players WHERE player_id = $1`;
            const values = [id];
            const { rows } = await pool.query(query, values);
            console.log(rows);
            return rows;
        } catch (error) {
            console.log(error);
            return error;
        }
    },



    // SEASONS FUNCTIONS
    getLadderForSeason: async (season) => { // the query still contains lots of SQL comments, leaving them in there for now
        try {
            const query = `
                SELECT
                    team_name,
                    COALESCE(SUM(home.home_team_score), 0) + COALESCE(SUM(away.away_team_score), 0) AS "frames_for", -- COALESCE runs the first argument if it's not null, otherwise it uses the second argument (0)
                    COALESCE(SUM(home.away_team_score), 0) + COALESCE(SUM(away.home_team_score), 0) AS "frames_against" --  double quotes for these column aliases because "for" may be a SQL keyword
                FROM teams
                LEFT JOIN matches AS home -- left join as that particular team may not always be the home team in that match but we still want to count their score
                    ON home.home_team_id = teams.team_id
                LEFT JOIN matches AS away -- as stated above, if that team isn't the home team, they'd have null values so now we're looking for when they were the away team to get their data
                    ON away.away_team_id = teams.team_id
                WHERE teams.season = $1
                GROUP BY teams.team_id;`;
            const values = [season];

            const { rows } = await pool.query(query, values);
            return rows;
        } catch (error) {
            return error;
        }
    },
    getLadderForSeasonAndWeek: async (season, week) => { // the query still contains lots of SQL comments, leaving them in there for now
        try {
            const query = `
                SELECT
                    team_name,
                    COALESCE(SUM(home.home_team_score), 0) + COALESCE(SUM(away.away_team_score), 0) AS "frames_for", -- COALESCE runs the first argument if it's not null, otherwise it uses the second argument (0)
                    COALESCE(SUM(home.away_team_score), 0) + COALESCE(SUM(away.home_team_score), 0) AS "frames_against" --  double quotes for these column aliases because "for" may be a SQL keyword
                FROM teams
                LEFT JOIN matches AS home -- left join as that particular team may not always be the home team in that match but we still want to count their score
                    ON home.home_team_id = teams.team_id
                LEFT JOIN matches AS away -- as stated above, if that team isn't the home team, they'd have null values so now we're looking for when they were the away team to get their data
                    ON away.away_team_id = teams.team_id
                WHERE (teams.season = $1) AND (home.week <= $2 OR away.week <= $2)
                GROUP BY teams.team_id;`;
            const values = [season, week];

            const { rows } = await pool.query(query, values);
            return rows;
        } catch (error) {
            return error;
        }
    },
    getPlayersForSeason: async (season) => {
        try {
            const query = `
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
                    WHERE matches.season = $1) AS home
                    ON players.player_id = home.player_one_id
                LEFT JOIN
                    (SELECT frames.*
                    FROM matches
                    INNER JOIN frames
                        ON matches.match_id = frames.match_id
                    WHERE matches.season = $1) AS away
                    ON players.player_id = away.player_two_id
                GROUP BY players.player_id;`;
            const values = [season];

            const { rows } = await pool.query(query, values);
            return rows;
        } catch (error) {
            return error;
        }
    },

    

    // TEAMS FUNCTIONS
    getAllTeams: async () => {
        try {
            const query = `
                SELECT team_name, ARRAY_AGG(season) AS seasons
                FROM teams
                GROUP BY team_name;`;

            const { rows } = await pool.query(query);
            return rows;
        } catch (error) {
            return error;
        }
    },
    getOneTeam: async (id) => {
        try {
            const query = `
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
                WHERE teams.team_id = $1
                GROUP BY teams.team_id;`;
            const values = [id];

            const { rows } = await pool.query(query, values);
            return rows;
        } catch (error) {
            return error;
        }
    },
    getOneTeamScore: async (id) => {
        try {
            const query = `
                SELECT
                    teams.team_name,
                    COALESCE(SUM(home.home_team_score), 0) + COALESCE(SUM(away.away_team_score), 0) AS "frames_for", -- COALESCE runs the first argument if it's not null, otherwise it uses the second argument (0)
                    COALESCE(SUM(home.away_team_score), 0) + COALESCE(SUM(away.home_team_score), 0) AS "frames_against"
                FROM teams
                LEFT JOIN matches AS home
                    ON home.home_team_id = teams.team_id
                LEFT JOIN matches AS away
                    ON away.away_team_id = teams.team_id
                WHERE teams.team_id = $1
                GROUP BY teams.team_id;`;
            const values = [id];

            const { rows } = await pool.query(query, values);
            return rows;
        } catch (error) {
            return error;
        }
    }
}