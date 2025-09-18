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
docker compose -f docker-compose.yml up --build
```

4. Open the frontend in a browser at `http://localhost:8081` (port may vary based on compose file). Open the browser console — the frontend WASM module will fetch `http://backend:8080/` (or proxied origin) and log `Hello World`.

5. Notes about frontend assets

- Ensure compiled frontend assets are present in `frontend/dist/` (the compose frontend service copies `frontend/dist/` into the nginx image). For example, run the wasm build inside the dev container:

```bash
# inside dev image
cd frontend && wasm-pack build --target web --out-dir ../frontend/dist
```


5. Run contract tests (inside the dev container):

```bash
./dev.sh test -- test_contract_hello_run.sh
```

Notes

- The repository enforces container-first workflows; run build/test steps inside the dev container per Constitution.
- The quickstart assumes the `docker-compose.yml` in this spec directory defines the services and networks.
