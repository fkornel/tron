#!/usr/bin/env bash

# Placeholder frontend build script for specs/003-extend-the-full (T022)
# Intended to be run inside the dev container per repository Constitution.
# This script documents the commands to build the Rust/WASM frontend and
# also provides a lightweight local fallback that copies pre-built files
# into ./dist/ so the Docker build and local testing can proceed.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIST_DIR="$ROOT_DIR/dist"

echo "Building frontend (placeholder)..."

# Real build steps (run inside dev container):
# 1. Install wasm-pack (if not installed):
#    curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
# 2. Build the package targeting 'web' and output to ../frontend/dist
#    cd $ROOT_DIR
#    wasm-pack build --target web --out-dir dist
# 3. Ensure bootstrap.js and the generated wasm file exist in dist/

# Local fallback: if a placeholder dist/ exists at repo root (frontend/dist/index.html), use it.
mkdir -p "$DIST_DIR"
if [ -f "$ROOT_DIR/index.html" ]; then
  echo "Detected existing frontend/index.html — copying to dist/ as index.html"
  cp "$ROOT_DIR/index.html" "$DIST_DIR/index.html"
fi

# If there are prebuilt static files under ../frontend/dist (repo may include them), copy them
if [ -f "$ROOT_DIR/../frontend/dist/index.html" ]; then
  echo "Copying existing repo placeholder dist files into frontend/dist"
  cp -r "$ROOT_DIR/../frontend/dist/"* "$DIST_DIR/" || true
fi

# As a final fallback, write a minimal bootstrap and placeholder WASM file marker
if [ ! -f "$DIST_DIR/index.html" ]; then
  cat > "$DIST_DIR/index.html" <<'EOF'
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>Frontend Placeholder</title>
    <script src="/static/bootstrap.js"></script>
  </head>
  <body>
    <h1>Frontend Placeholder</h1>
    <p>Console should show: Hello World (once backend is reachable)</p>
  </body>
</html>
EOF
fi

if [ ! -f "$DIST_DIR/bootstrap.js" ]; then
  cat > "$DIST_DIR/bootstrap.js" <<'EOF'
// Placeholder bootstrap.js — in a real build this loads the wasm and starts the app
console.log('frontend bootstrap placeholder');
fetch('/').then(r=>r.text()).then(t=>console.log('backend says:', t)).catch(e=>console.warn('fetch failed', e));
EOF
fi

chmod -R 755 "$DIST_DIR"

echo "Frontend build placeholder completed: $DIST_DIR contains:" 
ls -la "$DIST_DIR" || true

echo "Done"
