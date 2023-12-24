const express = require('express');
const app = express();

const BACKEND = `${process.env.BACKEND_HOST}:${process.env.BACKEND_PORT}`;

app.get('/jugadores', async (req, res) => {
    const response = await fetch(`${BACKEND}/jugadores`);

    res.send(await response.json());
});

app.get('/flights/count', async (req, res) => {
    const response = await fetch(`${BACKEND}/flights/count`);

    res.send(await response.json());
});

app.listen(process.env.SERVER_PORT || 3000, () => {
    console.log('Frontend listening on port 3000!');
});
