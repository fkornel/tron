#!/usr/bin/env bash
set -euo pipefail

# Final verification script (T019): builds (if needed) and runs contract + integration tests.
# Ensures containerized Hello world app behaves as expected.

IMAGE=${TRON_IMG:-tron-dev:001}
WORKDIR=/workspace
ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

cd "$ROOT_DIR"

if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "[verify] Image '$IMAGE' not found locally; building..." >&2
  docker build -t "$IMAGE" -f Dockerfile .
else
  echo "[verify] Using existing image '$IMAGE'" >&2
fi

# Run integration test (ensures build + run flow)
./tests/test_integration_quickstart.sh

# Run contract test
./specs/001-devcontainer-with-rust/contracts/tests/test_hello_run.sh

echo "[verify] All verification steps passed."