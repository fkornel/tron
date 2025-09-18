# Tasks: Replace Hello world CLI with an HTTP web server

**Input**: Design documents in `/home/fkornel/dev/tron/specs/002-replace-the-current`
**Prerequisites**: `/home/fkornel/dev/tron/specs/002-replace-the-current/plan.md` (present), research.md, data-model.md, contracts/

## Execution Flow (main)
1. Follow T001..T0XX in order, respecting dependencies and parallel flags.
2. Run tests (contract/integration/unit) before implementation tasks they depend on (TDD).
3. Commit after each completed task with focused commit messages.

## Task List

Phase 1 — Setup
- [x] T001 Create or update `Cargo.toml` with project metadata and add dependencies
  - File: `/home/fkornel/dev/tron/Cargo.toml`
  - Description: Ensure package name, edition, and dependencies include `axum = "0.8"` and `tokio = { version = "1", features = ["full"] }`. If you prefer zero deps, leave dependencies off and note the choice in the task output.
  - Dependency notes: Must be done before building or implementing server code.
- [x] T002 Ensure `rust-toolchain` contains `1.80.0` (already present)
  - File: `/home/fkornel/dev/tron/rust-toolchain`
  - Description: Verify `rust-toolchain` exists and is correct; update only if necessary.
- [x] T003 [P] Add formatting and linting configuration
  - Files: `/home/fkornel/dev/tron/rustfmt.toml`, `/home/fkornel/dev/tron/clippy.toml`, `/home/fkornel/dev/tron/.github/workflows/smoke.yml`, `Dockerfile`
  - Description: `rustfmt.toml` exists and was left or adjusted; added `clippy.toml`; updated `Dockerfile` to install `rustfmt` and `clippy` components; updated CI workflow `/home/fkornel/dev/tron/.github/workflows/smoke.yml` to run `cargo fmt -- --check` and `cargo clippy -- -D warnings` inside the dev container. Ensure `cargo fmt` and `cargo clippy` are runnable in the dev container by building the image and running the commands if desired.

Phase 2 — Tests (TDD: write tests that MUST fail before implementation)
- T004 [P] Add contract test runner (already present) — validate path
  - File: `/home/fkornel/dev/tron/specs/002-replace-the-current/contracts/tests/test_hello_run.sh`
  - Description: Ensure this script is executable (`chmod +x`) and uses the dev Docker image to run `cargo run`. This is a parallel task because it modifies only the contract test file (if any fix needed) and is independent of source files.
- T005 [P] Add integration test that performs `curl` to `/` and asserts body
  - File: `/home/fkornel/dev/tron/tests/test_integration_quickstart.sh`
  - Description: Ensure integration script exists and contains the steps to run the dev container and assert `Hello World` on `GET /`. Mark [P] because it is a script separate from source code.
- T006 [P] Add unit test placeholder for greeting behavior (failing)
  - File: `/home/fkornel/dev/tron/tests/test_unit_greeting.rs`
  - Description: Add a unit test that calls `greeting()` (or a public function to be created) and expects `Hello World`. The test should fail because the function isn't implemented yet (TDD).

Phase 3 — Core Implementation (after tests fail)
- T007 Implement `src/main.rs` with an `axum` HTTP server that exposes `/` and `/health`
  - File: `/home/fkornel/dev/tron/src/main.rs`
  - Description: Create a server binding to `0.0.0.0:${PORT:-8080}` (read from `PORT` env or default to 8080). Implement `GET /` returning status 200, header `Content-Type: text/plain; charset=utf-8`, and body exactly `Hello World`. Implement `GET /health` returning 200 and `Hello World` (or `OK`). Ensure `cargo run` starts the server. Do NOT add extra logging that changes response body.
  - Dependency notes: After T001, T004-006 tests should fail before this task is implemented.
- T008 Implement a small module or function for the greeting used by unit tests
  - File: `/home/fkornel/dev/tron/src/lib.rs`
  - Description: Create a `pub fn greeting() -> &'static str` returning `"Hello World"` and wire it into `main.rs` HTTP handler so unit tests can call it.
  - Dependency notes: This is the unit-level implementation that satisfies T006.
- T009 [P] Add simple request logging middleware (separate file to allow parallel work)
  - File: `/home/fkornel/dev/tron/src/middleware/logging.rs`
  - Description: Implement minimal logging of incoming requests (method, path) to `stdout`. This should not affect responses.

Phase 4 — Integration & Validation
- T010 Run contract test `specs/.../contracts/tests/test_hello_run.sh` and fix runtime issues
  - File: `/home/fkornel/dev/tron/specs/002-replace-the-current/contracts/tests/test_hello_run.sh`
  - Command/Agent: `bash /home/fkornel/dev/tron/specs/002-replace-the-current/contracts/tests/test_hello_run.sh`
  - Description: Run the script; if it fails because the server isn't binding correctly or `Content-Type` mismatch, adjust `src/main.rs` or headers. This task depends on T007.
- T011 Run integration test script and fix issues
  - File: `/home/fkornel/dev/tron/tests/test_integration_quickstart.sh`
  - Command/Agent: `bash /home/fkornel/dev/tron/tests/test_integration_quickstart.sh`
  - Description: Execute and ensure test passes. Fix networking/binding if necessary. Depends on T007.
- T012 Run unit tests and fix failures
  - Command/Agent: `cargo test --manifest-path /home/fkornel/dev/tron/Cargo.toml --test test_unit_greeting.rs` or `cargo test`
  - Description: Ensure the unit test for `greeting()` passes. Depends on T008.

Phase 5 — Polish
- T013 [P] Add `README` or update `quickstart.md` with final verified commands
  - File: `/home/fkornel/dev/tron/README.md` or update `/home/fkornel/dev/tron/specs/002-replace-the-current/quickstart.md`
  - Description: Ensure quickstart matches the exact commands used in contract/integration tests.
- T014 [P] Add unit tests for edge cases (405 on POST /, 404 on unknown path)
  - File: `/home/fkornel/dev/tron/tests/test_unit_errors.rs`
  - Description: Add tests asserting `405` for POST `/` and `404` for unknown path. These are parallel if implemented in separate test files.
- T015 [P] Ensure formatting and linting passes in dev container
  - Command/Agent: `docker run --rm -v "$PWD":/workspace -w /workspace tron-dev:001 sh -c "cargo fmt -- --check && cargo clippy -- -D warnings"`
  - Description: Run formatting and lint checks; fix issues.

## Task Ordering & Dependencies
- Setup: T001 → T002 → T003
- Tests (T004-T006) must be added and fail before Core Implementation (T007-T008)
- Core Implementation (T007, T008) unlocks Integration tasks (T010-T012)
- Polish tasks (T013-T015) run after core features and tests pass

## Parallel Execution Guidance & Examples
- Parallel group 1 (run together): T004, T005, T006 (all test files/scripts are separate and independent) — Command example:
  - bash -c "chmod +x /home/fkornel/dev/tron/specs/002-replace-the-current/contracts/tests/test_hello_run.sh && /home/fkornel/dev/tron/specs/002-replace-the-current/contracts/tests/test_hello_run.sh & /home/fkornel/dev/tron/tests/test_integration_quickstart.sh & cargo test --manifest-path /home/fkornel/dev/tron/Cargo.toml --test test_unit_greeting.rs & wait"
- Parallel group 2 (run together after core impl): T009, T013, T014, T015

## Exact Agent Commands (examples LLM can run)
- Create/update Cargo.toml: Edit file `/home/fkornel/dev/tron/Cargo.toml` and add dependencies `axum = "0.8"` and `tokio = { version = "1", features = ["full"] }`.
- Build & run server locally in dev container:
  - `docker build -t tron-dev:001 -f /home/fkornel/dev/tron/Dockerfile /home/fkornel/dev/tron`
  - `docker run --rm -p 8080:8080 -v "/home/fkornel/dev/tron":/workspace -w /workspace tron-dev:001 sh -c "cargo run"`
- Run contract test script:
  - `bash /home/fkornel/dev/tron/specs/002-replace-the-current/contracts/tests/test_hello_run.sh`
- Run integration script:
  - `bash /home/fkornel/dev/tron/tests/test_integration_quickstart.sh`

## Validation Checklist (must be satisfied before marking done)
- [ ] All contract files have corresponding test tasks (T004 covers existing script; openapi.yaml documented)
- [ ] All entities in `data-model.md` have model tasks (T008 implements greeting function; HTTP Endpoint is implemented by handlers)
- [ ] Tests were added before implementation and initially failed (T004-T006 before T007-T008)
- [ ] Each task includes an exact file path or exact command to run

---
Generated by `/home/fkornel/dev/tron/.specify/templates/tasks-template.md` and the implementation plan at `/home/fkornel/dev/tron/specs/002-replace-the-current/plan.md`.
