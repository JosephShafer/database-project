
const { Client } = require('pg');
const client = new Client({
    user: 'joey',
    password: 'password',
    host: 'localhost',
    port: 5432,
    database: 'flowershop',
  });

  client.connect();


module.exports = client;
  