const express = require('express');
const router = express.Router();


const { getAllTeams, getOneTeam, getOneTeamScore } = require("../db");


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

// not returning past players since a new team_id is created every new season. maybe we can search by matching team names instead??
router.get('/:id', async (req, res) => {
    // return team with a particular id, players for that year, and their score (frames_for and frames_against)
    const id = req.params.id;
    try {
        const rows = await getOneTeam(id);
        const score_rows = await getOneTeamScore(id); // make a second query to get this team's overall score in that season
        const { frames_for, frames_against } = score_rows[0];
        rows[0] = {
            ...rows[0],
            frames_for,
            frames_against
        }; // spread and insert frames_for and frames_against into the rows data to be sent to client
        res.send(rows);
    } catch (error) {
        console.log(error);
        res.status(500).send({ message: "Something went wrong", error });
    }
});

module.exports = router; // don't forget about this!