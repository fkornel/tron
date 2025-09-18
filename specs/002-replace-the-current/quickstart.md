# Quickstart: Run the Hello World HTTP server

This quickstart shows how to build and run the project locally inside the development container and how to verify the `GET /` endpoint returns `Hello World`.

Prerequisites:
- Docker installed (development and CI workflows run inside the dev image per project constitution).

Commands:

1. Build and run inside the dev image (recommended):

```bash
# Build the development image (if not already built)
docker build -t tron-dev:001 -f Dockerfile .

# Run the server inside the dev image, forwarding port 8080
docker run --rm -p 8080:8080 -v "$PWD":/workspace -w /workspace tron-dev:001 sh -c "cargo run"
```

2. Verify endpoint:

```bash
# From host, once container is running
curl -i http://localhost:8080/
# Expect: HTTP/1.1 200 OK
# Content-Type: text/plain; charset=utf-8
# Body: Hello World
```

3. Run contract test (from repository root):

```bash
./specs/002-replace-the-current/contracts/tests/test_hello_run.sh
```

Notes:
- Ensure the server binds to `0.0.0.0` or `localhost` inside the container so tests can reach it via the mapped port.
- The dev image approach enforces the project's constitution rule to perform builds and runs inside containers.
