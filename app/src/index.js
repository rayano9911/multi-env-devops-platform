const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Multi-Env DevOps Platform',
    environment: process.env.ENVIRONMENT || 'dev',
    version: '0.1.0'
  });
});

app.listen(port, () => {
  console.log(`App running on port ${port}`);
});
