# Research: Replace Hello world CLI with an HTTP web server

## Decision
- Implement a minimal Rust HTTP server that listens on a configurable port (default `8080`) and responds to `GET /` with status `200`, header `Content-Type: text/plain; charset=utf-8`, and body exactly `Hello World`.

## Rationale
- The feature spec explicitly requires a plaintext response and no TLS; Rust is already used in the repository and the dev environment targets Rust (`rust-toolchain` present), so implementing the server in Rust keeps the stack consistent and minimizes onboarding cost.
- A minimal HTTP server using the Rust standard library (std::net + tiny HTTP handling) or a lightweight crate such as `tiny-http` or `axum` are viable options. For minimal dependencies and simplicity, using `axum` is recommended for clarity and easy route handling, but `std::net` with a tiny router is sufficient for this small feature.

## Alternatives Considered
- Use the standard library only (no external crates): reduces dependencies but requires manual HTTP parsing and more code for correct header handling.
- Use `tiny-http`: lightweight, easy to add, but less ergonomic than `axum` for routing.
- Use `axum` with `tokio`: ergonomic and robust, but pulls in async runtime (`tokio`) increasing binary size. Acceptable for dev image.

## Chosen Approach
- Implement using the Rust `axum` crate with `tokio` runtime to provide a straightforward and well-tested HTTP server. It simplifies future route additions (e.g., `/health`) and produces clear, maintainable code.

## Resolved Unknowns
- FR-006 and FR-007 were resolved in the spec: plaintext and no TLS required.
- No additional unknowns remain.

## Impact on Testing
- Contract and integration tests (shell scripts) will run the project inside the dev container and perform HTTP requests against the server on the configured port. Ensure `cargo run` starts the server and binds to 0.0.0.0:${PORT} or at least localhost inside the container so the test harness can access it.

## Next Steps
- Add `axum` and `tokio` dependencies to `Cargo.toml` or implement a minimal server using the standard library if a no-dependency approach is preferred.
- Implement server handlers for `/` and `/health`.
- Ensure logging is enabled for request/response lines.
