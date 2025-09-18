#!/usr/bin/env bash
set -euo pipefail

# Integration test: build the image and run the web server, then assert HTTP response
IMAGE=tron-dev:001
WORKDIR=/workspace
PORT=8080

# Build the development image (quickstart step 1)
docker build -t "$IMAGE" -f Dockerfile .

# Run the application in background and forward port
CONTAINER_ID=$(docker run -d -p ${PORT}:${PORT} -v "$PWD":$WORKDIR -w $WORKDIR $IMAGE sh -c "cargo run --quiet")
trap 'docker rm -f $CONTAINER_ID >/dev/null 2>&1 || true' EXIT
sleep 1

# Request the root path
HTTP_OUT=$(curl -sS -D - "http://localhost:${PORT}/" || true)
STATUS_LINE=$(echo "$HTTP_OUT" | sed -n '1p' | tr -d '\r')
BODY=$(echo "$HTTP_OUT" | sed -n '2,$p' | tr -d '\r')

if [[ "$STATUS_LINE" != *"200"* ]]; then
  echo "Integration test failed: expected status 200, got:" >&2
  echo "$STATUS_LINE" >&2
  exit 1
fi

if ! echo "$HTTP_OUT" | rg -i "^Content-Type: text/plain" >/dev/null 2>&1; then
  echo "Integration test failed: expected 'Content-Type: text/plain' header" >&2
  echo "$HTTP_OUT" >&2
  exit 1
fi

BODY_TRIMMED=$(echo -n "$BODY" | sed -e 's/^[ \t\n\r]*//' -e 's/[ \t\n\r]*$//')

if [[ "$BODY_TRIMMED" != "Hello World" ]]; then
  echo "Integration test failed: expected 'Hello World' in body, got:" >&2
  echo "$BODY_TRIMMED" >&2
  exit 1
fi

echo "Integration test passed: Content-Type text/plain and body 'Hello World'"
