const express = require('express');
const router = express.Router();

router.get('/', async (req, res) => {
  // return list of teams
});

router.get('/:id', async (req, res) => {
  // return team with id, current and past players
});

module.exports = router; // don't forget about this!