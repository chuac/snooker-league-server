const express = require('express');
const router = express.Router();

const { getAllPlayers,
        getOnePlayer
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