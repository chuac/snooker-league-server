require('dotenv').config(); // sets up .env environment variables

const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();


app.use(bodyParser.json()); // using bodyParser to parse JSON bodies into JS objects
app.use(cors()); // enable cross-origin resource sharing


app.listen(process.env.EXPRESS_PORT || 3000, () => { // listens to the port defined in our .env file OR default of 3000
    console.log(`Server listening on port ${process.env.EXPRESS_PORT || 3000}`);
});