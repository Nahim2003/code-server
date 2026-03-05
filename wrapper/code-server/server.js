const express = require("express");
const http = require("http");
const { createProxyMiddleware } = require("http-proxy-middleware");

const app = express();
const PORT = process.env.WRAPPER_PORT || 3001;

app.get("/health", (req, res) => res.json({ status: "ok" }));

const proxy = createProxyMiddleware({
  target: "http://127.0.0.1:8080",

  // IMPORTANT: do NOT rewrite Host to 127.0.0.1
  changeOrigin: false,

  ws: true,
  xfwd: true,

  onProxyReq: (proxyReq, req) => {
    // Preserve the public host, so code-server is happy
    if (req.headers.host) proxyReq.setHeader("Host", req.headers.host);
    proxyReq.setHeader("X-Forwarded-Proto", "https");
    proxyReq.setHeader("X-Forwarded-Host", req.headers.host);
  },

  onProxyReqWs: (proxyReq, req) => {
    // Same for WebSockets
    if (req.headers.host) proxyReq.setHeader("Host", req.headers.host);
    proxyReq.setHeader("X-Forwarded-Proto", "https");
    proxyReq.setHeader("X-Forwarded-Host", req.headers.host);
  },

  onError: (err, req, res) => {
    console.error("PROXY ERROR:", err.code || err.message);
    res.status(502).send("Proxy error");
  },
});

app.use("/", proxy);

const server = http.createServer(app);
server.on("upgrade", proxy.upgrade);

server.listen(PORT, "0.0.0.0", () => {
  console.log(`Wrapper listening on 0.0.0.0:${PORT}`);
});
