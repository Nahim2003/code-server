// 1) Imports
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

// 2) App + port
const app = express();
const PORT = 3000; // you can keep this for now

// 3) Health route
app.get('/health', (req, res) => {
  res.json({"status": "ok"});
});

// 4) Proxy everything else to code-server on 127.0.0.1:8080
// Hint: look at http-proxy-middleware docs for an example of
// app.use('/', createProxyMiddleware({ target: ..., changeOrigin: true, ws: true }))


app.use('/', createProxyMiddleware({
  ws: true,
  target: 'http://127.0.0.1:8080',
  changeOrigin: true,
  pathRewrite: {
    '^/api': '', // Remove /api prefix when forwarding to target
  },
  onProxyReq: (proxyReq, req, res) => {
    // You can modify the proxy request here if needed
  },
  onError: (err, req, res) => {
    res.status(500).send('Proxy error');
  },
}));

// 5) Start the server
app.listen(PORT, () => {
  console.log(`Proxy server is running on http://localhost:${PORT}`);
});
