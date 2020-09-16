const express = require('express');
const router = express.Router();

const { getLadderForSeason, getLadderForSeasonAndWeek } = require("../db");

router.get('/:season/table', async (req, res) => {
    // return UNSORTED league table for that year, currently an array of team objects with their for/against key/value pairs
    const season = req.params.season;
    try {
        const rows = await getLadderForSeason(season);
        res.send(rows);
    } catch (error) {
        console.log(error);
        res.status(500).send({ message: "Something went wrong", error });
    }
});

router.get("/:season/:week/table", async (req, res) => {
    // return UNSORTED league table for that year, up to a certain week
    const { season, week } = req.params;
    try {
        const rows = await getLadderForSeasonAndWeek(season, week);
        res.send(rows);
    } catch (error) {
        console.log(error);
        res.status(500).send({ message: "Something went wrong", error });
    }
});

router.get('/players', async (req, res) => {
    // return player statistics for that year
});

module.exports = router;