Development & Contributor Guide

Host Runtime Rule
- This repository enforces the Host Runtime Rule defined in `.specify/memory/constitution.md`:
  - The host machine used for development or automation provides only the `docker` command (or an equivalent OCI-compatible runtime).
  - All development activities — **Build**, **Test**, and **Run** — MUST execute inside the repository's development container image.

Quickstart (container-first)
- Build the dev image: `./dev.sh build`
- Run the app (inside container): `./dev.sh run`
- Run all Rust tests (inside container): `./dev.sh test`
- Open an interactive shell in the dev image: `./dev.sh shell`
- Run an arbitrary command inside the dev image: `./dev.sh exec -- <cmd>`
- Clean/remove the dev image: `./dev.sh clean`

Notes & Testing
- Do not install Rust, Cargo, or build dependencies on the host.
- Contract test (uses Docker to run containerized app): `bash specs/001-devcontainer-with-rust/contracts/tests/test_hello_run.sh`
- Integration quickstart test: `bash tests/integration/test_quickstart.sh`
- CI jobs SHOULD run the same commands inside the dev image to ensure reproducibility.

Exceptions
- Temporary exceptions to the Host Runtime Rule require:
  - A documented migration plan in the PR description, and
  - Explicit approval from a project maintainer.

Reference
- Constitution (Host Runtime Rule): `.specify/memory/constitution.md`
- Dev helper: `./dev.sh` (environment variables: `TRON_IMG`, `DOCKERFILE`, `DOCKER_RUN_OPTS`, `WORKDIR`)

If you want, I can also add a short CONTRIBUTING.md pointing contributors to this file and the constitution.