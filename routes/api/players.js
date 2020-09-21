const express = require('express');
const router = express.Router();

const { getAllPlayers,
        getOnePlayer,
        addOnePlayer
    } = require('../db');

router.get('/', async (req, res) => {
    // return list of all players
    try {
        const rows = await getAllPlayers();
        res.send(rows);
    } catch (error) {
        console.log(error);
        res.status(500).send({ message: 'Something went wrong', error});
    }
});

router.post('/', async (req, res) => {
    // add one player to the DB, would return with success status 201 and that player's new ID
    const { player_name } = req.body; // in our client, we POST JSON data into req.body

    try {
        const result = await addOnePlayer(player_name);
        res
            .status(201)
            .send({ message: "New player inserted", player_id: result.player_id });
    } catch (error) {
        res
            .status(500)
            .send({message: "Something went wrong", error: error.message});
    }
});

router.get('/:id', async (req, res) => {
    //   return player with id, current and past team, frames played, and other relevant info
    const id = req.params.id; // :id from URL can be accessed at req.params.id
    try {
        const rows = await getOnePlayer(id);
        res.send(rows);
    } catch (error) {
        console.log(error);
        res.status(500).send({ message: "Something went wrong", error });
    }
});

module.exports = router;