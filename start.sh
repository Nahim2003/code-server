#!/bin/sh
set -e
echo "Starting code-server..."
code-server --bind-addr 0.0.0.0:8080 &

echo "Starting node wrapper..."
cd /app/wrapper/code-server
node server.js
