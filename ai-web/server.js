#!/usr/bin/env node

const path = require('path');
const { execFile } = require('child_process');
const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

const aiScript = 'ai'; // Assume 'ai' is in PATH via Nix wrapper
const aiOptions = { timeout: 120000 };

app.post('/chat', (req, res) => {
  const { backend, prompt } = req.body || {};

  if (!backend || !prompt || typeof backend !== 'string' || typeof prompt !== 'string') {
    return res.status(400).json({ error: 'backend and prompt are required' });
  }

  const args = [backend, prompt];

  execFile(aiScript, args, aiOptions, (err, stdout, stderr) => {
    if (err) {
      console.error('AI backend error:', err, stderr?.toString?.() || '');
      return res
        .status(500)
        .json({ error: 'AI backend failed', detail: stderr?.toString?.() || String(err) });
    }

    return res.json({ reply: (stdout || '').toString().trim() });
  });
});

app.listen(PORT, () => {
  console.log(`Nymeria AI Console listening on http://localhost:${PORT}`);
});
