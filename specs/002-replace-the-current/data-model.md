# Data Model: Replace Hello world CLI with an HTTP web server

This feature has minimal data requirements — the system is an HTTP endpoint with no persistent storage.

## Entities

- HTTP Endpoint
  - Fields:
    - `path`: string (e.g., `/`, `/health`)
    - `method`: string (e.g., `GET`)
    - `response_code`: integer (e.g., `200`)
    - `response_headers`: map<string,string> (e.g., `Content-Type: text/plain; charset=utf-8`)
    - `response_body`: string (exact match `Hello World` for `/`)

## Validation Rules
- For `/`:
  - `method` must allow `GET`.
  - `response_body` must be exactly `Hello World` (case-sensitive, no extra whitespace).
  - `Content-Type` header must include `text/plain` and `charset=utf-8`.

## State Transitions
- Not applicable; endpoints are stateless for this feature.

