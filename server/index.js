const express = require('express');
const { Pool } = require('pg');
const { S3 } = require('aws-sdk');
const pool = new Pool({
  host: process.env.DB_ENDPOINT,
  port: 5432,
  user: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});
const app = express();
const s3 = new S3();
const port = 3000;

app.get('/', async (req, res) => {
  try {
    const data = await pool.query('SELECT * FROM pg_catalog.pg_tables;');
    console.log(data);

    const listObjects = await s3.listObjectsV2({
      Bucket: process.env.ASSETS_BUCKET,
    }).promise();
    console.log(listObjects);

    res.status(200);
    res.send({
      data,
      listObjects,
    });
  } catch (err) {
    console.log(err);

    res.status(400);
    return res.send(err);
  }
})

app.listen(port, () => console.log(`Example app listening on port ${port}!`));
