# Quickstart: Run the frontend + backend with Docker Compose

Prerequisites

- Docker and docker-compose installed
- Build the dev image and the project artifacts inside the dev container per repository README

Steps

1. Build the backend image (inside the dev container):

```bash
./dev.sh build
# Alternatively, build the backend image with:
# docker build -t backend:local -f Dockerfile .
```

2. Build the frontend WASM bundle (inside the dev container):

```bash
# Example using wasm-pack (inside the dev image):
# cd frontend && wasm-pack build --target web --out-dir ../frontend/dist
```

3. Start services via Docker Compose (run from repo root):

```bash
docker compose -f specs/003-extend-the-full/docker-compose.yml up --build
```

4. Open the frontend in a browser at `http://localhost:8080` (port may vary based on compose file). Open the browser console — the frontend WASM module will fetch `http://backend:8080/` (or proxied origin) and log `Hello World`.

5. Run contract tests (inside the dev container):

```bash
./dev.sh test -- test_contract_hello_run.sh
```

Notes

- The repository enforces container-first workflows; run build/test steps inside the dev container per Constitution.
- The quickstart assumes the `docker-compose.yml` in this spec directory defines the services and networks.
