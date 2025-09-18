#!/usr/bin/env bash
set -euo pipefail

# Integration test: reproduce quickstart steps using the repo-root Dockerfile
IMAGE=tron-dev:001
WORKDIR=/workspace

# Build the development image (quickstart step 1)
docker build -t "$IMAGE" -f Dockerfile .

# Run the Hello world application from the container (quickstart step 2)
OUT=$(docker run --rm -v "$PWD":$WORKDIR -w $WORKDIR $IMAGE cargo run --quiet 2>&1 || true)

if [[ "$OUT" != *"Hello world"* ]]; then
  echo "Integration test failed: expected 'Hello world' in output, got:" >&2
  echo "$OUT" >&2
  exit 1
fi

echo "Integration test passed: 'Hello world' found in output"
