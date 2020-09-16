const express = require('express');
const router = express.Router();

const { getAllTeams } = require("../db");

router.get('/', async (req, res) => {
    // return list of teams, and all the years they participated in
    try {
        const rows = await getAllTeams();
        res.send(rows);
    } catch (error) {
        console.log(error);
        res.status(500).send({ message: 'Something went wrong', error});
    }
});

router.get('/:id', async (req, res) => {
    // return team with id, current and past players
});

module.exports = router; // don't forget about this!