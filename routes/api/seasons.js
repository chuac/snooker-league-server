const express = require('express');
const router = express.Router();

router.get('/table', async (req, res) => {
  // return league table for that year
});

router.get('/players', async (req, res) => {
  // return player statistics for that year
});

module.exports = router;