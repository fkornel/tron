#!/usr/bin/env bash
set -euo pipefail

# Contract test: verify backend returns OK at /health
# This script is intended to be executed inside the development container.

HOST=${HOST:-localhost}
PORT=${PORT:-8080}

echo "Checking backend health endpoint at http://$HOST:$PORT/health"
resp=$(curl -sS -w "%{http_code}" "http://$HOST:$PORT/health" -o /tmp/resp_body || true)
body=$(cat /tmp/resp_body || true)
code=$resp

if [ "$code" != "200" ]; then
  echo "Expected HTTP 200 but got $code"
  exit 2
fi

# Trim whitespace
trimmed=$(echo -n "$body" | awk '{$1=$1};1')
if [ "$trimmed" != "OK" ]; then
  echo "Unexpected body: '$trimmed'"
  exit 3
fi

echo "Contract test passed: backend returned 'OK'"
