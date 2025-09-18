# Quickstart: Devcontainer With Rust Toolchain And Hello World

Date: 2025-09-18

Purpose: Provide step-by-step instructions for a contributor with only Docker available to verify the project dev environment and run the sample Hello world application.

Prerequisites:
- Docker installed and running on the host machine.

Steps:
1. Build the development image (from repository root):

   ```bash
   docker build -t tron-dev:001 -f Dockerfile .
   ```

2. Run the Hello world application from the container:

   ```bash
   docker run --rm -v "$PWD":/workspace -w /workspace tron-dev:001 cargo run --quiet
   ```

   Expected output (stdout):

   Hello world

3. If the container fails to build or run, inspect logs and retry provisioning. The build scripts should surface clear errors (e.g., missing toolchain or network issues).

4. CI smoke-check example (GitHub Actions snippet):

   ```yaml
   name: Smoke check
   on: [push, pull_request]
   jobs:
     smoke:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - name: Build image
           run: docker build -t tron-dev:001 -f Dockerfile .
         - name: Run Hello world
           run: docker run --rm -v "$PWD":/workspace -w /workspace tron-dev:001 cargo run --quiet
   ```

Notes:
- The repository includes a `rust-toolchain` file to pin the Rust version used by the build.
- The exact greeting is expected to be: "Hello world" (case-sensitive).
