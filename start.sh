#!/bin/sh
set -e

exec code-server \
  --bind-addr 0.0.0.0:8080 \
  --proxy-domain tm.nahim-dev.com \
  --trusted-origins https://tm.nahim-dev.com
