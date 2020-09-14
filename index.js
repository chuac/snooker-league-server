require('dotenv').config(); // sets up .env environment variables

const express = require('express');
const cors = require('cors');

const app = express();


app.use(cors()); // enable cross-origin resource sharing

app.use(express.json()); // parse JSON bodies into JS objects. Is this doubling up? because of body parser? Mosh used this
// Chris: looks like bodyParser has been built-in to Express as of version 4.16+, so no need for that extra package :thumbsup:
app.use('/api/seasons', require('./routes/api/seasons'));
app.use('/api/teams', require('./routes/api/teams'));
app.use('/api/players', require('./routes/api/players'));

app.listen(process.env.EXPRESS_PORT || 3000, () => {
  // listens to the port defined in our .env file OR default of 3000
  console.log(`Server listening on port ${process.env.EXPRESS_PORT || 3000}`);
});
