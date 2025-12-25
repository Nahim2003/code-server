// wrapper/code-server/server.js

const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();

// Simple health check so ALB / curl can verify the service
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Proxy EVERYTHING else to code-server running on port 8080
app.use(
  '/',
  createProxyMiddleware({
    target: 'http://127.0.0.1:8080',
    changeOrigin: true,
    ws: true, // proxy websockets too
    pathRewrite: {
      '^/': '/', // keep paths as-is
    },
  })
);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Proxy server is running on http://localhost:${PORT}`);
});
