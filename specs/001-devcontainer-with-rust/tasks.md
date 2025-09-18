# Tasks: Devcontainer With Rust Toolchain And “Hello World” Application

**Input**: Design documents from `/home/fkornel/dev/tron/specs/001-devcontainer-with-rust/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/, quickstart.md

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → Extract tech stack (Rust, Docker), structure (single project)
2. Load optional design documents:
   → data-model.md: No entities → no model tasks
   → contracts/: hello-run contract → contract test task
   → research.md: Decisions → setup tasks (Dockerfile, rust-toolchain, wrapper script, CI smoke)
   → quickstart.md: Scenario → integration test task
3. Generate tasks by category:
   → Setup: docker image, rust toolchain pin, cargo project init
   → Tests: contract test (already scaffolded), integration (quickstart scenario), unit tests placeholder
   → Core: implement hello world app, dev wrapper script
   → Integration: CI smoke workflow
   → Polish: docs refinement, lint/format config
4. Apply task rules (tests before implementation, parallel where independent)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency notes
7. Provide parallel execution example
8. Validate completeness (all contracts/tests mapped)
9. Return SUCCESS
```

## Format: `[ID] [P] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths

## Phase 3.1: Setup
 - [x] T001 Create `rust-toolchain` file at `/home/fkornel/dev/tron/rust-toolchain` pinning version (e.g., `1.80.0`).
 - [x] T002 [P] Create Dockerfile at `/home/fkornel/dev/tron/Dockerfile` using pinned Rust base image.
- [x] T003 [P] Initialize Cargo project (if not exists) at `/home/fkornel/dev/tron/` with `Cargo.toml` and `src/main.rs` (Hello world placeholder added).
- [x] T004 [P] Add `dev.sh` helper script at `/home/fkornel/dev/tron/dev.sh` to wrap build/run commands via Docker.

## Phase 3.2: Tests First (TDD)
**CRITICAL: These tests MUST exist and (initially) fail before implementation adjustments.**
- [ ] T006 [P] Ensure contract test script `/home/fkornel/dev/tron/specs/001-devcontainer-with-rust/contracts/tests/test_hello_run.sh` is executable and asserts exact `Hello world`.
- [ ] T007 [P] Create integration test `/home/fkornel/dev/tron/tests/integration/test_quickstart.sh` reproducing quickstart steps (expects container run output `Hello world`).
- [ ] T008 Add unit test scaffold `/home/fkornel/dev/tron/tests/unit/test_greeting.rs` asserting greeting function returns `Hello world` (will fail until function implemented).

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [ ] T009 Implement greeting function in `/home/fkornel/dev/tron/src/main.rs` returning exact string `Hello world` (ensure no newline mismatches if tests are strict).
- [ ] T010 Update main to call greeting function and print output once (no extra logging) in `/home/fkornel/dev/tron/src/main.rs`.
- [ ] T011 Add README section in `/home/fkornel/dev/tron/README.md` referencing quickstart and container usage.
- [ ] T012 Implement `dev.sh` logic (if placeholder added) for build, run, test commands in `/home/fkornel/dev/tron/dev.sh`.

## Phase 3.4: Integration
- [ ] T013 Create CI smoke workflow at `/home/fkornel/dev/tron/.github/workflows/smoke.yml` building image and running `cargo run` inside container.
- [ ] T014 Add Makefile at `/home/fkornel/dev/tron/Makefile` with targets: `build-image`, `run`, `test` wrapping docker commands (optional but improves DX).

## Phase 3.5: Polish
- [ ] T015 [P] Add lint/config: `/home/fkornel/dev/tron/rustfmt.toml` or confirm default formatting (document decision in README).
- [ ] T016 [P] Add documentation refinement to `/home/fkornel/dev/tron/specs/001-devcontainer-with-rust/quickstart.md` linking CI badge once workflow exists.
- [ ] T017 [P] Add CONTRIBUTING snippet or section in `/home/fkornel/dev/tron/README.md` describing docker-only workflow.
- [ ] T018 Review and remove unused placeholder files (if any) in feature dir.
- [ ] T019 Final verification script `/home/fkornel/dev/tron/scripts/verify.sh` running contract + integration tests.

## Dependencies
- T001 before T002 (Dockerfile references pinned version) and before T003 (toolchain consistency).
- T002 and T003 can run in parallel after T001.
- T004 depends on T002 (needs image name) and T003 (project path) → run after both.
- T006-T008 (tests) must complete (and initially fail) before T009-T010.
- T009 before T010 (function before call integration, if split) — can be merged if trivial.
- T011 after core implementation (needs reliable run instructions).
- T013 after T002 (image build) and T009-T010 (app runs correctly).
- Polish tasks (T015-T019) after integration tasks.

## Parallel Execution Example
```
# Example: Run independent setup tasks after pinning toolchain
Tasks: T002, T003 can execute in parallel once T001 is done.

# Tests phase parallel start
Tasks: T006, T007, T008 can run concurrently (distinct files: shell script, shell integration test, Rust unit test).

# Polish phase parallel group
Tasks: T015, T016, T017 can run concurrently (config file, doc update, README section).
```

## Validation Checklist
- [x] All contracts have corresponding tests (hello-run → T006 contract test; integration scenario → T007)
- [x] All entities have model tasks (no entities defined; none required)
- [x] All tests come before implementation (T006-T008 precede T009+)
- [x] Parallel tasks only touch separate files
- [x] Each task specifies exact file path
- [x] No [P] tasks modify same file

## Task Agent Examples
```
# Example command payloads for a task runner agent:
Task: "T002 Create Dockerfile" → Edit file /home/fkornel/dev/tron/specs/001-devcontainer-with-rust/Dockerfile with base image and labels.
Task: "T007 Create integration test" → Write /home/fkornel/dev/tron/tests/integration/test_quickstart.sh script replicating quickstart steps.
Task: "T013 Create CI workflow" → Write /home/fkornel/dev/tron/.github/workflows/smoke.yml with build & run jobs.
```

## Notes
- Ensure contract & integration tests fail prior to implementation to uphold TDD.
- Keep image minimal; avoid unnecessary packages.
- Avoid adding extra dependencies before justified by future specs.
