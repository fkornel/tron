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

# Run the container in background and forward port
CONTAINER_ID=$(docker run -d -p ${PORT}:${PORT} -v "$PWD":$WORKDIR -w $WORKDIR $IMAGE sh -c "cargo run --quiet")
trap 'docker rm -f $CONTAINER_ID >/dev/null 2>&1 || true' EXIT

# Wait a moment for the server to start
sleep 1

# Perform the request
HTTP_OUT=$(docker run --rm --network host curlimages/curl:8.4.0 -sS -D - "http://host.docker.internal:${PORT}/" || true)

# Fallback for systems where host.docker.internal is not available
if [[ -z "$HTTP_OUT" ]]; then
  HTTP_OUT=$(curl -sS -D - "http://localhost:${PORT}/" || true)
fi

# Check status code and headers and body
STATUS_LINE=$(echo "$HTTP_OUT" | sed -n '1p' | tr -d '\r')
BODY=$(echo "$HTTP_OUT" | sed -n '2,$p' | tr -d '\r')

if [[ "$STATUS_LINE" != *"200"* ]]; then
  echo "Contract test failed: expected status 200, got:" >&2
  echo "$STATUS_LINE" >&2
  exit 1
fi

# Check Content-Type header
if ! echo "$HTTP_OUT" | rg -i "^Content-Type: text/plain" >/dev/null 2>&1; then
  echo "Contract test failed: expected 'Content-Type: text/plain' header" >&2
  echo "$HTTP_OUT" >&2
  exit 1
fi

# Trim whitespace from body
BODY_TRIMMED=$(echo -n "$BODY" | sed -e 's/^[ \t\n\r]*//' -e 's/[ \t\n\r]*$//')

if [[ "$BODY_TRIMMED" != "Hello World" ]]; then
  echo "Contract test failed: expected body 'Hello World' got:" >&2
  echo "$BODY_TRIMMED" >&2
  exit 1
fi

echo "Contract test passed: 200, Content-Type text/plain, body 'Hello World'"
