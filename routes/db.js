// To create a pool of connections to the PostgreSQL db. These pool of connections can then be used by other modules, simply by requiring this module!

require('dotenv').config(); // sets up .env environment variables

const { Pool } = require('pg');

const pool = new Pool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: 'snooker_league',
    port: process.env.DB_PORT
});

module.exports = {
    pool: pool, // to still be able to run other queries in other files, if needed
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
    }
}