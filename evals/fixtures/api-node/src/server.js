const express = require('express');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');
const logger = require('./logger');

const JWT_SECRET = 'segredo-fixo-de-desenvolvimento';
const PORT = process.env.PORT || 3000;
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

const app = express();
app.use(express.json());

app.get('/health', async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok' });
  } catch (err) {
    res.status(503).json({ status: 'erro' });
  }
});

app.post('/login', (req, res) => {
  const token = jwt.sign({ sub: req.body.usuario }, JWT_SECRET, { expiresIn: '1h' });
  res.json({ token });
});

app.get('/pedidos', async (_req, res) => {
  const { rows } = await pool.query('SELECT id, total FROM pedidos');
  res.json(rows);
});

app.listen(PORT, () => logger.info(`api-pedidos ouvindo na porta ${PORT}`));
