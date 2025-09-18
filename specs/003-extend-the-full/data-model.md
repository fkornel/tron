# Data Model: Extend the full solution with Docker Compose

This feature does not introduce persistent data models. The system is a frontend/backend integration where the frontend fetches a plaintext greeting from the backend.

Entities

- GreetingResponse
  - type: string
  - description: Plaintext greeting returned from `GET /` on `backend`

Validation

- The greeting response must be a valid UTF-8 string
- Trimmed non-empty string

Relationships

- None

State

- N/A

