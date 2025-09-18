# tron

Quickstart (container-first)

This repository uses a container-first developer workflow. Build and run the Rust project inside the provided development Docker image.

Build the dev image:

```
./dev.sh build
```

Run the application:

```
./dev.sh run
```

Run tests inside the container:

```
./dev.sh test
```

Notes

- The project pins the Rust toolchain in `rust-toolchain`.
- Tests live under `tests/` and are executed inside the dev container.
- If you need an interactive shell in the image, use `./dev.sh shell`.

## Contributing

- Workflow: all development and tests run inside the provided Docker image; avoid building on the host.
- Tests: add unit tests under `tests/` (top-level) and integration scripts under `tests/` or `specs/` as appropriate.
- Run common tasks via the Makefile: `make build-image`, `make run`, `make test`.
- Formatting: project uses `rustfmt`; run `rustfmt` inside the dev image or `cargo fmt` via `./dev.sh test` (if desired).
