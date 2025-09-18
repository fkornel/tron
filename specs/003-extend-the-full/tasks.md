# Tasks: Extend the full solution with Docker Compose

**Input**: Design documents from `/home/fkornel/dev/tron/specs/003-extend-the-full/`
**Prerequisites**: `/home/fkornel/dev/tron/specs/003-extend-the-full/plan.md` (required), `/home/fkornel/dev/tron/specs/003-extend-the-full/research.md`, `/home/fkornel/dev/tron/specs/003-extend-the-full/data-model.md`, `/home/fkornel/dev/tron/specs/003-extend-the-full/contracts/`, `/home/fkornel/dev/tron/specs/003-extend-the-full/quickstart.md`

Execution notes
- All build and test commands must be executed inside the dev container using `/home/fkornel/dev/tron/dev.sh` per the Constitution.
- Use absolute paths shown for files and scripts.

Task ID format: T### (three digits). Tasks marked with [P] can run in parallel (no shared files).

Phase 3.1 — Setup

- T001 Setup dev image and verify build environment
  - Action: From repo root run inside host: `/home/fkornel/dev/tron/dev.sh build`
  - Verify: `docker image ls` shows image named `tron-dev:001` (or specified `TRON_IMG`) and `./dev.sh shell` opens a shell.
  - Output files modified: none
  - Dependencies: none
  - Status: completed

- T002 [P] Add frontend scaffold directory `frontend/` and minimal files
  - Action: Create directory `/home/fkornel/dev/tron/frontend/` and add:
    - `/home/fkornel/dev/tron/frontend/index.html` with basic HTML that loads `/static/bootstrap.js` and `/static/pkg/frontend_wasm.js`.
    - `/home/fkornel/dev/tron/frontend/Dockerfile` that uses `nginx:alpine` to serve `/usr/share/nginx/html` and copies `dist/` into that directory.
  - Files to create (LLM should write these exact files):
    - `/home/fkornel/dev/tron/frontend/index.html`
    - `/home/fkornel/dev/tron/frontend/Dockerfile`
  - Verify: Files exist and are readable.
  - Parallelizable: yes [P]
  - Status: completed

- T003 [P] Add `docker-compose.yml` at repo root to define `frontend` and `backend` services
  - Action: Create `/home/fkornel/dev/tron/docker-compose.yml` with services:
    - `backend`: build context `.` using repo Dockerfile, set `PORT=8080`, expose `8080:8080`.
    - `frontend`: build context `./frontend`, expose `8081:80` (map host 8081), and depends_on `backend`.
  - Verify: `docker compose -f /home/fkornel/dev/tron/docker-compose.yml config` exits 0.
  - Parallelizable: yes [P]
  - Status: completed

Phase 3.2 — Tests First (TDD)

- T010 [P] Create contract test for `GET /` in top-level tests
  - Action: Create executable script `/home/fkornel/dev/tron/tests/test_contract_backend_root.sh` with the same behavior as `test_contract_hello_run.sh` but explicitly checks `GET /` per OpenAPI.
  - Verify: File exists and is executable (`chmod +x`).
  - Dependency: none (can be written now)
  - Status: completed

- T011 [P] Create contract test for `GET /health` in top-level tests
  - Action: Create script `/home/fkornel/dev/tron/tests/test_contract_backend_health.sh` that `curl` GETs `/health` and asserts 200 and body `OK`.
  - Verify: File exists and is executable.
  - Dependency: none
  - Status: completed

Phase 3.3 — Core Implementation (after tests fail)

- T020 Implement backend `Dockerfile` build entrypoint (ensure image builds)
  - Action: Ensure `/home/fkornel/dev/tron/Dockerfile` builds the backend image used by compose. If adjustments are needed, modify `Dockerfile` to produce a runnable backend image with `cargo build --release` and `CMD` to run the binary. Commit changes.
  - Verify: `docker build -t backend:local .` inside dev container completes successfully.
  - Dependency: T001

- T021 Implement backend service start via compose
  - Action: Ensure `docker-compose.yml`'s backend service starts the compiled binary. Use `docker compose -f /home/fkornel/dev/tron/docker-compose.yml up --build -d` to run.
  - Verify: `curl -sS http://localhost:8080/` returns `Hello World`.
  - Dependency: T020

- T022 Implement frontend WASM build pipeline (inside dev container)
  - Action: Add build steps to produce `frontend/dist/` with `frontend_wasm.wasm` and `bootstrap.js`. For LLM execution: write a placeholder build script `/home/fkornel/dev/tron/frontend/build_frontend.sh` that documents commands to run inside the dev container to produce `dist/` (e.g., `wasm-pack build --target web --out-dir dist`), mark it executable.
  - Verify: `/home/fkornel/dev/tron/frontend/dist/` exists after running build steps in dev container.
  - Dependency: T002

- T023 Hook frontend image to serve built `dist/` via its Dockerfile
  - Action: Update `/home/fkornel/dev/tron/frontend/Dockerfile` to copy `dist/` into Nginx html directory; ensure build succeeds.
  - Verify: `docker build -t frontend:local ./frontend` inside dev container completes successfully.
  - Dependency: T022

Phase 3.4 — Integration

- T030 [P] Compose up and validate integration scenario from quickstart
  - Action: From repo root (inside dev container) run: `docker compose -f /home/fkornel/dev/tron/specs/003-extend-the-full/docker-compose.yml up --build --abort-on-container-exit` and wait until both services are healthy.
  - Verify: `curl -sS http://localhost:8080/` returns `Hello World`; frontend served at `http://localhost:8080` loads and console log shows `Hello World` (manual browser step optional).
  - Dependency: T021, T023
  - Parallelizable: yes [P]

Phase 3.5 — Polish

- T040 [P] Unit tests: add a small unit test for `tron::greeting()` in `tests/test_unit_greeting.rs`
  - Action: Create `/home/fkornel/dev/tron/tests/test_unit_greeting.rs` with a Rust test that asserts `tron::greeting()` returns `"Hello World"`.
  - Verify: `./dev.sh test` inside dev container runs unit tests and this test exists (it may fail until implementation is correct).
  - Dependency: none

- T041 [P] Documentation: update `/home/fkornel/dev/tron/specs/003-extend-the-full/quickstart.md` with exact compose commands and verification steps (already present; ensure examples match actual ports and filenames).
  - Action: Edit the file at `/home/fkornel/dev/tron/specs/003-extend-the-full/quickstart.md` to include exact commands used in tasks.
  - Verify: File updated and committed.
  - Dependency: none

Parallel groups and agent commands

- Group A (can execute in parallel): T002, T003, T010, T011, T040, T041
  - Example agent command for T002: TaskAgent.run --write-file "/home/fkornel/dev/tron/frontend/index.html" "<html>..."
  - Example agent command for T003: TaskAgent.run --write-file "/home/fkornel/dev/tron/specs/003-extend-the-full/docker-compose.yml" "version: '3'..."
  - Example agent command for T010: TaskAgent.run --write-file "/home/fkornel/dev/tron/tests/test_contract_backend_root.sh" "#!/usr/bin/env bash..."

- Group B (sequential): T020 -> T021 -> T022 -> T023 -> T030
  - These tasks depend on built artifacts from previous steps and therefore should be executed in order.

Validation checklist (automatic)
- [ ] One contract test created for each endpoint in `/home/fkornel/dev/tron/specs/003-extend-the-full/contracts/openapi.yaml` (expected: `/`, `/health`).
- [ ] One model task for each entity in `/home/fkornel/dev/tron/specs/003-extend-the-full/data-model.md` (expected: `GreetingResponse` → model validation task considered optional since no persistent store).
- [ ] Quickstart scenario mapped to integration task T030.

Files created/edited by these tasks (examples)
- /home/fkornel/dev/tron/frontend/index.html
- /home/fkornel/dev/tron/frontend/Dockerfile
- /home/fkornel/dev/tron/frontend/build_frontend.sh
- /home/fkornel/dev/tron/specs/003-extend-the-full/docker-compose.yml
- /home/fkornel/dev/tron/tests/test_contract_backend_root.sh
- /home/fkornel/dev/tron/tests/test_contract_backend_health.sh
- /home/fkornel/dev/tron/tests/test_unit_greeting.rs

Notes
- Each task description includes exact file paths to create or edit and clear verification commands to run inside the dev container.
- Tasks marked [P] do not touch the same files and can be executed in parallel by agents.

