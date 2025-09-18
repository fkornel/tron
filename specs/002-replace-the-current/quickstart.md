# Quickstart: Run the Hello World HTTP server

This quickstart shows how to build and run the project locally inside the development container and how to verify the `GET /` endpoint returns `Hello World`.

Prerequisites:
- Docker installed (development and CI workflows run inside the dev image per project constitution).

Commands:

1. Build and run inside the dev image (recommended):

```bash
# Build the development image (if not already built)
./dev.sh build

# Run the server inside the dev image, forwarding port 8080
./dev.sh run
```

2. Verify endpoint:

```bash
# From host, once container is running
curl -i http://localhost:8080/
# Expected status: HTTP/1.1 200 OK
# Expected header: Content-Type: text/plain
# Expected body: Hello World
```

3. Run contract test (from repository root):

```bash
./specs/002-replace-the-current/contracts/tests/test_hello_run.sh
```

Notes:
- Ensure the server binds to `0.0.0.0` inside the container so tests can reach it via the mapped port.
- The dev image approach enforces the project's constitution rule to perform builds and runs inside containers.
