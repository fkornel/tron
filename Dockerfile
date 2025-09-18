# Multi-stage Dockerfile for building the Tron backend
# Builds a release binary in a Rust builder stage and copies it into a slim runtime image.

FROM rust:1.80 as builder

WORKDIR /usr/src/tron

# Install platform packages needed for some crates (if required)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       pkg-config \
       libssl-dev \
       ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Cache dependencies by copying manifests first
COPY Cargo.toml Cargo.lock ./

# Copy the source code
COPY . .

# Build the release binary
RUN cargo build --release

# Runtime image
FROM debian:bookworm-slim

# Install CA certs for HTTPS
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/tron/target/release/tron /usr/local/bin/tron

# Default port - can be overridden by env
ENV PORT=8080
EXPOSE 8080

# Run the compiled binary
CMD ["/usr/local/bin/tron"]
