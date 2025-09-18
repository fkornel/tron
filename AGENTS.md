# AGENTS.md (opencode assistant context file)

This file records the key technical context for AI agents working on this repository. Keep it short and update only when new technologies are introduced.

=== BEGIN AUTO-GENERATED SECTION ===
- Language: Rust 1.80.0
- Primary crates: axum, tokio, hyper, humantime
- Dev workflow: Container-first (use `./dev.sh` inside the dev image)
- Test location: Top-level `tests/` directory; test filenames should indicate type (unit/integration/contract)
- Feature: specs/003-extend-the-full — Docker Compose integration for frontend (WASM) + backend (Rust)
- Dev Compose: repo-root `docker-compose.yml` defines `backend` and `frontend` services (production-like images); spec `docker-compose.yml` (kept in `specs/003-extend-the-full`) provides a workspace-mounted dev variant that runs `cargo run`.
=== END AUTO-GENERATED SECTION ===

Manual notes:
- When updating, ensure the auto-generated section remains concise (<= 150 lines) for agent token efficiency.
