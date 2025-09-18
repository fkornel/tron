# Implementation Plan: Devcontainer With Rust Toolchain And “Hello World” Application

**Branch**: `001-devcontainer-with-rust` | **Date**: 2025-09-18 | **Spec**: /home/fkornel/dev/tron/specs/001-devcontainer-with-rust/spec.md
**Input**: Feature specification from `/home/fkornel/dev/tron/specs/001-devcontainer-with-rust/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Fill the Constitution Check section based on the content of the constitution document.
4. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
Primary requirement: provide a reproducible, Docker-based development environment that contains the Rust toolchain and a minimal runnable "Hello world" Rust application so contributors can develop and verify the toolchain without installing Rust locally.

Technical approach: use Docker as the single surface for development. Prefer a prebuilt Rust image or a small project-specific dev image (built from a Dockerfile) that pins the Rust toolchain version via a `rust-toolchain` file. Make running the app a single obvious command that can be executed via `docker run` (no VSCode remote dev dependencies). Provide a CI smoke-check that runs the same containerized command.

## Technical Context
**Language/Version**: Rust — pin via a `rust-toolchain` or `rust-toolchain.toml` file (concrete version to be chosen at implementation time; example placeholder: `1.80.0`).
**Primary Dependencies**: `cargo`, `rustc` (provided by toolchain inside container); build-essential packages only if native dependencies are needed.
**Storage**: N/A for initial feature (no persistence required).
**Testing**: Unit + integration via `cargo test`; acceptance/smoke via containerized `cargo run` driven by a shell test.
**Target Platform**: Linux (Docker container)
**Project Type**: Single CLI-style starter app (Option 1: single project)
**Performance Goals**: N/A
**Constraints**: Development must work on a machine that only has Docker installed (no local Rust). No VSCode-specific devcontainer assumptions — use Docker CLI flows. If additional services are needed later (DB), add via Docker composition or separate containers.
**Scale/Scope**: Minimal starter application; focuses on reproducibility and onboarding.

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The constitution file at `/home/fkornel/dev/tron/.specify/memory/constitution.md` contains placeholders and no explicit constraints or gating rules. Based on available content:
- No explicit prohibitions found that block a Docker-centric dev flow.
- Principle checks (TDD, simplicity, observability) should be followed during implementation.

Decision: INITIAL CONSTITUTION CHECK — PASS (no violations detected; ensure tests are added early during implementation per constitution guidance).

## Project Structure

### Documentation (this feature)
```
/home/fkornel/dev/tron/specs/001-devcontainer-with-rust/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
│   └── tests/           # contract test stubs (expected to fail until implemented)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
# Option 1: Single project (DEFAULT)
src/
├── main.rs (or crate layout)
Cargo.toml

tests/
├── contract/
└── integration/
```

**Structure Decision**: Option 1 (single CLI-style crate). This is appropriate for a minimal starter Rust app.

## Phase 0: Outline & Research

1. Extract unknowns from Technical Context:
   - Exact Rust version to pin (MSRV) — action: choose concrete version when implementing and place in `rust-toolchain`.
   - Dev image strategy: use official Rust image vs build custom image with selected tools. Action: pick approach in research below.
   - Readiness behavior: ensure container readiness and fail-fast on provisioning errors.
   - CI smoke job: how to run containerized verification on CI runners.

2. Tasks generated for research (these will be addressed now):
   - Research container strategies and recommend one.
   - Document recommended developer run commands for docker-only environments.
   - Recommend `rust-toolchain` pinning strategy and sample file contents.
   - Draft a sample CI smoke job that uses Docker to run the starter app.

3. Consolidate findings in `research.md` (created).

**Output**: `/home/fkornel/dev/tron/specs/001-devcontainer-with-rust/research.md` — resolves the open questions above.

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. `data-model.md` (created) — This feature has no domain data model; document that there are no persistent entities for this feature.

2. Generate contracts from functional requirements (created under `/home/fkornel/dev/tron/specs/001-devcontainer-with-rust/contracts/`):
   - `hello-run` contract: describes the expected run action and exact `stdout` output "Hello world" and exit code 0.

3. Generate contract tests (stubs):
   - A shell test script that attempts to run the app inside a container and asserts the expected output. This test is expected to fail until the starter app exists (TDD flow).

4. Extract test scenarios from user stories -> quickstart.md (created) describing step-by-step verification that a contributor can run the app and see `Hello world`.

5. Agent file update: If you use the agent context update, call:
```
.specify/scripts/bash/update-agent-context.sh opencode
```
This is optional here; run it when you want to refresh the agent context.

**Output**: `/home/fkornel/dev/tron/specs/001-devcontainer-with-rust/data-model.md`, `/home/fkornel/dev/tron/specs/001-devcontainer-with-rust/contracts/`, `/home/fkornel/dev/tron/specs/001-devcontainer-with-rust/quickstart.md`.

## Phase 2: Task Planning Approach

**Task Generation Strategy** (described — do NOT create `tasks.md` in /plan):
- Base tasks on the quickstart steps and contracts.
- Example tasks:
  - Add `rust-toolchain` file with pinned version. [P]
  - Add `Dockerfile` for dev image and confirm build. [P]
  - Add Cargo project skeleton (Cargo.toml, src/main.rs) implementing Hello world. [P]
  - Add contract test runner (`contracts/tests/test_hello_run.sh`) and verify it fails (TDD). [P]
  - Implement app to make contract test pass. [P]
  - Add CI smoke job that runs contract test in a container. [P]

**Ordering Strategy**:
- TDD-first: create tests and failing contract test, then implement.
- Parallelizable items: Dockerfile & rust-toolchain creation can be parallel with test scaffolding.

## Complexity Tracking
*No constitution violations detected; no complexity exemptions required.*

## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [ ] Complexity deviations documented

---
*Based on Constitution file: `/home/fkornel/dev/tron/.specify/memory/constitution.md`*
