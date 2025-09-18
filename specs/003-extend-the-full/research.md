# Research: Extend the full solution with Docker Compose

## Decision
Create a Docker Compose setup with two services:
- `frontend`: static web server serving `index.html` and a Rust/WASM bundle for client logic
- `backend`: reuse the existing server (renamed to `backend`) exposing `GET /` and `/health`

Rationale: This matches the user's intent to have two independent images and enables local development via `docker-compose up`.

## Alternatives Considered
- Single monorepo service serving both frontend and backend from the same binary: Rejected because the requirement explicitly asks for independent images.
- Using a non-WASM frontend (pure JS): Rejected because the user requested Rust/WASM for frontend logic.

## Implementation Notes
- The frontend will use a minimal Web server (e.g., `nginx` or `httpd`) to serve `index.html` plus compiled `wasm` and an auto-generated JS bootstrap file. The Rust/WASM module will handle the fetch and console logging logic.
- The backend is an existing Rust `axum` server in this repo. We'll expose its image as `backend` and map ports to `localhost` for local dev.
- CORS: Prefer same-origin by configuring the frontend to proxy requests to the backend via `docker-compose` network and mapping ports appropriately. If frontend is served on a different origin, add permissive CORS for the dev environment to allow fetches from the frontend.

## Unknowns (resolved)
- Backend path: `/` (resolved)
- Browser support: modern Chrome, Firefox, Safari (resolved)
- Frontend UI: console-only with minimal auto-generated JS bootstrap (resolved)

## Tools & Constraints
- Container-first development is mandatory per Constitution: all builds and tests must run inside the dev container image using `./dev.sh`.
- Tests must be placed under `tests/` at repository root and named according to the Test Naming Rule.

## Outputs for Phase 1
- `data-model.md`, `contracts/openapi.yaml`, `quickstart.md`

