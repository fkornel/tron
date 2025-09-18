#!/usr/bin/env bash
set -euo pipefail

# Contract test: Run the Hello world web server in the dev image and assert HTTP response
IMAGE=tron-dev:001
WORKDIR=/workspace
PORT=8080

# Build image if not present (safe to run)
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  docker build -t "$IMAGE" -f Dockerfile .
fi

# Run the server and test inside a single container so it stops automatically
# This avoids host port binding conflicts by testing against localhost inside the container.
HTTP_OUT=$(docker run --rm -e PORT=${PORT} -v "$PWD":$WORKDIR -w $WORKDIR $IMAGE bash -lc '
  set -euo pipefail
  # ensure cargo is on PATH
  export PATH=/usr/local/cargo/bin:$PATH
  # install curl quietly if missing
  if ! command -v curl >/dev/null 2>&1; then apt-get update >/dev/null 2>&1 && apt-get install -y --no-install-recommends curl >/dev/null 2>&1; fi
  # start server in background and capture logs
  /usr/local/cargo/bin/cargo run --quiet > /tmp/server.log 2>&1 &
  server_pid=$!
  # try requests until we get a response or timeout
  max_attempts=30
  attempt=0
  while [ $attempt -lt $max_attempts ]; do
    if curl -sS --max-time 2 -D /tmp/http_headers -o /tmp/http_body "http://127.0.0.1:${PORT}/"; then
      break
    fi
    attempt=$((attempt+1))
    sleep 1
  done
  # print headers then body to stdout for host parsing
  if [ -f /tmp/http_headers ]; then cat /tmp/http_headers; fi
  if [ -f /tmp/http_body ]; then cat /tmp/http_body; fi
  # if we failed to get HTTP output, dump server log to stderr for debugging
  if [ ! -s /tmp/http_body ]; then echo "=== server.log ===" >&2; cat /tmp/server.log >&2 || true; fi
  # stop the server before exiting the container
  kill "$server_pid" >/dev/null 2>&1 || true
  wait "$server_pid" 2>/dev/null || true
' || true)

# Check status code and headers and body
STATUS_LINE=$(printf '%s' "$HTTP_OUT" | sed -n '1p' | tr -d '\r')

# Determine body as the last non-empty line of the response (robust against headers)
BODY_TRIMMED=$(printf '%s' "$HTTP_OUT" | awk 'BEGIN{last=""} {gsub("\r",""); if($0 ~ /[^[:space:]]/) last=$0} END{print last}')
# Trim whitespace
BODY_TRIMMED=$(echo -n "$BODY_TRIMMED" | sed -e 's/^[ \t\n\r]*//' -e 's/[ \t\n\r]*$//')

if [[ "$STATUS_LINE" != *"200"* ]]; then
  echo "Contract test failed: expected status 200, got:" >&2
  echo "$STATUS_LINE" >&2
  exit 1
fi

# Check Content-Type header (use grep for portability)
if ! echo "$HTTP_OUT" | grep -i -E "^Content-Type: text/plain" >/dev/null 2>&1; then
  echo "Contract test failed: expected 'Content-Type: text/plain' header" >&2
  echo "$HTTP_OUT" >&2
  exit 1
fi

if [[ "$BODY_TRIMMED" != "Hello World" ]]; then
  echo "Contract test failed: expected body 'Hello World' got:" >&2
  echo "$BODY_TRIMMED" >&2
  exit 1
fi

echo "Contract test passed: 200, Content-Type text/plain, body 'Hello World'"
