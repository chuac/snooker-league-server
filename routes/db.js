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
    getLadderForSeason: async (season) => { // the query still contains lots of SQL comments, leaving them in there for now
        try {
            const query = `
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
                HAVING teams.season = $1 -- need to use HAVING instead of WHERE, if we have a GROUP BY in the query
                ;`;
            const values = [season];

            const { rows } = await pool.query(query, values);
            return rows;
        } catch (error) {
            return error;
        }
    }
}