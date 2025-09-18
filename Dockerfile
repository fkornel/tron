# Development image for the "Devcontainer With Rust" feature
# Pinned to the repository toolchain: /home/fkornel/dev/tron/rust-toolchain -> 1.80.0
# This image is intended for local/CI smoke checks; project files are mounted at runtime.

FROM rust:1.80.0

# Keep labels minimal and explicit
LABEL org.opencontainers.image.title="tron-dev" \
      org.opencontainers.image.description="Development image for Tron (Rust 1.80.0)"

# Install a few minimal packages commonly needed when building Rust crates
# - git: fetch dependencies from VCS
# - ca-certificates: TLS for downloads
# - build-essential / pkg-config / libssl-dev: common native build deps (kept minimal)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       git \
       ca-certificates \
       build-essential \
       pkg-config \
       libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Use a workspace directory that will be mounted by the quickstart/contract tests
WORKDIR /workspace

# Ensure cargo uses a writable location for cached artifacts
ENV CARGO_HOME=/usr/local/cargo \
    RUSTUP_TOOLCHAIN=1.80.0

# Default to an interactive shell; quickstart runs `cargo run` explicitly.
CMD ["bash"]
