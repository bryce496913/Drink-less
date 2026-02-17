const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const app = express();
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

const db = new sqlite3.Database('./sms_logs.db');
db.run('CREATE TABLE IF NOT EXISTS logs (id INTEGER PRIMARY KEY AUTOINCREMENT, deviceId TEXT, amount REAL, createdAt TEXT)');

app.post('/sms/inbound', (req, res) => {
  const deviceId = req.body.deviceId || 'default';
  const amount = parseFloat(req.body.Body || req.body.body || '0');
  if (Number.isNaN(amount)) return res.status(400).json({ error: 'Body must be numeric' });
  db.run('INSERT INTO logs(deviceId, amount, createdAt) VALUES (?, ?, ?)', [deviceId, amount, new Date().toISOString()]);
  res.json({ ok: true });
});

app.get('/sync', (req, res) => {
  const deviceId = req.query.deviceId || 'default';
  db.all('SELECT * FROM logs WHERE deviceId = ? ORDER BY id DESC LIMIT 50', [deviceId], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ logs: rows });
  });
});

app.listen(3000, () => console.log('SMS companion listening on 3000'));
