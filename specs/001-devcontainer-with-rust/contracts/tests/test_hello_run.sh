#!/usr/bin/env bash
set -euo pipefail

# Contract test: Run the Hello world app in the dev image and assert output
IMAGE=tron-dev:001
WORKDIR=/workspace

# Attempt to run the containerized app and capture output
OUT=$(docker run --rm -v "$PWD":$WORKDIR -w $WORKDIR $IMAGE cargo run --quiet 2>&1 || true)

if [[ "$OUT" != *"Hello world"* ]]; then
  echo "Contract test failed: expected 'Hello world' in output, got:" >&2
  echo "$OUT" >&2
  exit 1
fi

echo "Contract test passed: 'Hello world' found in output"
