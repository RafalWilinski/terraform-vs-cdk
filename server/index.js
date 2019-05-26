const express = require('express');
const { Client } = require('pg');
const client = new Client({
  host: process.env.DB_ENDPOINT,
  port: 5432,
  user: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
});
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  client.connect();
  client.query('SELECT * FROM pg_catalog.pg_tables;', (err, data) => {
    if (err) {
      res.statusCode(400);
      return res.send(err)
    }
    client.end();

    res.send({
      data
    });
  });
})

app.listen(port, () => console.log(`Example app listening on port ${port}!`));
