# Research: Devcontainer With Rust Toolchain And Hello World

Date: 2025-09-18

## Decisions

1. Devcontainer strategy

Decision: Use a small custom `Dockerfile` built FROM the official Rust image (e.g., `rust:1.80-bullseye`), pinning the Rust toolchain with a `rust-toolchain` file. Rationale: Official images ensure compatibility and provide `rustup`, `cargo`, and `rustc` out of the box. Building a project-specific dev image lets us install only needed system packages and keep a reproducible image.

Alternatives considered:
- Use raw official image without project Dockerfile: simpler, but less control for adding system deps in future.
- Use multi-stage image to reduce final image size: unnecessary for development-focused image; keep simple.

2. Docker-only development flow

Decision: Provide `Dockerfile` and `Makefile`/scripts that allow contributors to build (`docker build -t tron-dev:001 .`) and run (`docker run --rm -v "$PWD":/workspace -w /workspace tron-dev:001 cargo run`) without VSCode. Also provide a short `./dev.sh` wrapper to simplify this.

Rationale: User requested no VSCode assumption and a machine with only Docker installed.

3. Toolchain pinning

Decision: Add `rust-toolchain` with a concrete version (e.g., `1.80.0`) to root so `rustup` in the container will use it. Document MSRV in `quickstart.md`.

4. Readiness behavior

Decision: Fail fast on provisioning errors — container build/run scripts should detect missing toolchain or install failures and surface a clear error message.

5. CI smoke-check

Decision: Provide a simple GitHub Actions workflow example that builds the dev image and runs the containerized `cargo run` as a smoke test. Keep workflow minimal and optional.

## Actionable research tasks
- Create `Dockerfile` and `dev.sh` wrapper.
- Create `rust-toolchain` file with chosen version.
- Create `Cargo.toml` and `src/main.rs` skeleton for Hello world.
- Create contract test script under `specs/.../contracts/tests/test_hello_run.sh` that runs the app in a container and checks stdout.
- Draft example GitHub Actions workflow file snippet in `quickstart.md`.

## References
- Official Rust Docker images: https://hub.docker.com/_/rust
- `rust-toolchain` pinning: https://doc.rust-lang.org/stable/rustup/overrides.html
