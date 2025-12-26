// wrapper/code-server/server.js

const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const PORT = 3000;

// Health check for ALB / GitHub Actions
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Proxy everything else to code-server on port 8080
app.use(
  '/',
  createProxyMiddleware({
    target: 'http://127.0.0.1:8080',
    changeOrigin: true,
    ws: true,
  })
);

app.listen(PORT, () => {
  console.log(`Proxy server is running on http://localhost:${PORT}`);
});
