# Tasks (Phase 2 - Planning Output)

This file describes the approach the `/tasks` command will take. Do NOT execute tasks here.

## Task Generation Strategy
- Use TDD order: write contract tests and unit tests first, then implement.
- Create tasks for building container images and running docker-compose for local integration.

## High-level Tasks
1. Create `specs/003-extend-the-full/docker-compose.yml` to define `frontend` and `backend` services. [P]
2. Add `frontend/` scaffold: `index.html`, `Dockerfile`, `dist/` output for wasm and bootstrap. [P]
3. Build Rust/WASM frontend bundle inside dev container and place output in `frontend/dist/`. [P]
4. Ensure `backend` service is buildable from repository root Dockerfile or add a small `backend/Dockerfile` that uses `./` repo build artifacts. [P]
5. Run `docker compose up --build` and validate quickstart steps. [S]
6. Implement failing contract tests (already present) and run in dev container. [P]
7. Add CI job to run contract tests inside dev container. [P]

## Ordering and Estimates
- Steps 1-3: setup and build — 1-2 hours
- Steps 4-6: integration and testing — 1-2 hours
- Step 7: CI integration — 30-60 minutes

## Notes
- All build and test steps must be performed inside the dev container per Constitution rules.

