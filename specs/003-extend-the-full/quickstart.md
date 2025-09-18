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
# Use the repo-root compose file. This builds images and starts them in the foreground.
docker compose -f docker-compose.yml up --build

# To run in detached mode:
docker compose -f docker-compose.yml up --build -d

# To stop and remove containers created by compose:
docker compose -f docker-compose.yml down
```

4. Verify the services

- Backend: `http://localhost:8080/` should return `Hello World`.
- Frontend: `http://localhost:8081/` serves the static site (NGINX) that loads the WASM bundle and logs `Hello World` to the browser console.

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
