#!/usr/bin/env bash
set -euo pipefail

# Integration test: Run the Hello World web server in the dev image and assert HTTP response
IMAGE=tron-dev:001
WORKDIR=/workspace
PORT=8080

# Build image if not present
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  docker build -t "$IMAGE" -f Dockerfile .
fi

# Try to start the container on an available host port (8080..8099)
CONTAINER_ID=""
HOST_PORT=""
for hp in $(seq 8080 8099); do
  CONTAINER_ID=$(docker run -d -e PORT=${PORT} -p ${hp}:${PORT} -v "$PWD":$WORKDIR -w $WORKDIR $IMAGE bash -lc "export PATH=/usr/local/cargo/bin:\$PATH && /usr/local/cargo/bin/cargo run --quiet") || true
  if [ -n "$CONTAINER_ID" ]; then
    # ensure container is running
    RUNNING=$(docker inspect --format='{{.State.Running}}' "$CONTAINER_ID" 2>/dev/null || echo "false")
    if [ "$RUNNING" = "true" ]; then
      HOST_PORT=$hp
      break
    else
      docker rm -f "$CONTAINER_ID" >/dev/null 2>&1 || true
      CONTAINER_ID=""
    fi
  fi
done

if [ -z "$CONTAINER_ID" ]; then
  echo "Integration test failed: could not start container on ports 8080-8099" >&2
  docker ps -a --filter "ancestor=$IMAGE" --format '{{.ID}} {{.Status}} {{.Names}}' >&2 || true
  exit 1
fi

# Ensure container cleaned up on exit
trap 'docker rm -f $CONTAINER_ID >/dev/null 2>&1 || true' EXIT

# Wait for server to start (retry curl)
max_attempts=30
attempt=0
HTTP_OUT=""
while [ $attempt -lt $max_attempts ]; do
  HTTP_OUT=$(curl -sS -D - --max-time 2 "http://127.0.0.1:${HOST_PORT}/" 2>/dev/null) && break || true
  attempt=$((attempt+1))
  sleep 1
done

if [ -z "$HTTP_OUT" ]; then
  echo "Integration test failed: no response from server" >&2
  docker logs "$CONTAINER_ID" >&2 || true
  exit 1
fi

# Parse status line and body (robust)
STATUS_LINE=$(printf '%s' "$HTTP_OUT" | sed -n '1p' | tr -d '\r')
BODY_TRIMMED=$(printf '%s' "$HTTP_OUT" | awk 'BEGIN{last=""} {gsub("\r",""); if($0 ~ /[^[:space:]]/) last=$0} END{print last}')
BODY_TRIMMED=$(echo -n "$BODY_TRIMMED" | sed -e 's/^[ \t\n\r]*//' -e 's/[ \t\n\r]*$//')

if [[ "$STATUS_LINE" != *"200"* ]]; then
  echo "Integration test failed: expected status 200, got:" >&2
  echo "$STATUS_LINE" >&2
  docker logs "$CONTAINER_ID" >&2 || true
  exit 1
fi

# Check Content-Type header
if ! printf '%s' "$HTTP_OUT" | grep -i -E "^Content-Type: text/plain" >/dev/null 2>&1; then
  echo "Integration test failed: expected 'Content-Type: text/plain' header" >&2
  echo "$HTTP_OUT" >&2
  docker logs "$CONTAINER_ID" >&2 || true
  exit 1
fi

if [[ "$BODY_TRIMMED" != "Hello World" ]]; then
  echo "Integration test failed: expected body 'Hello World' got:" >&2
  echo "$BODY_TRIMMED" >&2
  docker logs "$CONTAINER_ID" >&2 || true
  exit 1
fi

echo "Integration test passed: 200, Content-Type text/plain, body 'Hello World'"
