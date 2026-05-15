# Expense Tracker API

A personal finance REST API built in Go. Tracks cash across multiple buckets (wallet, bKash, bank, DPS), records every money movement in an append-only ledger, and reports live balances with Redis-cached aggregates.

**Single-user.** There is no signup flow — one user is seeded at startup via environment variables. All endpoints require a JWT except `POST /v1/auth/login` and `GET /v1/healthz`.

**Machine-readable spec:** [`openapi.yaml`](./openapi.yaml) — OpenAPI 3.0, suitable for code generation, Swagger UI, Postman import, and AI agents.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Environment Variables](#environment-variables)
3. [Running Locally](#running-locally)
4. [Running Tests](#running-tests)
5. [API Reference](#api-reference)
   - [Conventions](#conventions)
   - [Auth](#auth)
   - [Buckets](#buckets)
   - [People](#people)
   - [Tags](#tags)
   - [Transactions](#transactions)
   - [Reports](#reports)
   - [Reminders](#reminders)
6. [Error Reference](#error-reference)
7. [Data Model](#data-model)
8. [Architecture](#architecture)
9. [Development Guide](#development-guide)

---

## Quick Start

```bash
# 1. Clone and enter the directory
git clone <repo> && cd expense-tracker

# 2. Copy env template and fill in your values
cp .env.example .env

# 3. Start Postgres + Redis
make docker-up

# 4. Run the server (migrates and seeds automatically)
make run

# 5. Login
curl -s -X POST http://localhost:8080/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"you@example.com","password":"yourpassword"}' | jq .
```

---

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `DATABASE_URL` | **Yes** | — | PostgreSQL connection string, e.g. `postgres://user:pass@localhost:5432/expense?sslmode=disable` |
| `JWT_SECRET` | **Yes** | — | HMAC-SHA256 signing key. Minimum 32 characters. |
| `SEED_USER_EMAIL` | **Yes** | — | Email address for the single app user |
| `SEED_USER_PASSWORD` | **Yes** | — | Plaintext password (bcrypt-hashed on first startup, never stored in plain text) |
| `PORT` | No | `8080` | HTTP listen port |
| `REDIS_URL` | No | `redis://localhost:6379` | Redis connection string |
| `MIGRATIONS_PATH` | No | `internal/db/migrations` | Path to SQL migration files (override in Docker: `/app/migrations`) |
| `ENV` | No | — | Set to `production` for JSON-structured logs; omit for human-readable text logs |

---

## Running Locally

### Prerequisites

- Go 1.22+
- Docker (for Postgres + Redis, and for integration tests)
- [`sqlc`](https://sqlc.dev) — `brew install sqlc`
- [`golangci-lint`](https://golangci-lint.run) — `brew install golangci-lint` (optional, for `make lint`)
- [`migrate`](https://github.com/golang-migrate/migrate) CLI — `brew install golang-migrate` (optional, for manual migrations)

### Steps

```bash
# Start Postgres and Redis only
make docker-up

# Run the API (auto-runs migrations and seeds the user on first start)
make run
```

The server listens on `http://localhost:8080` by default.

### Full Docker Compose stack (API + Postgres + Redis)

```bash
cp .env.example .env
# Set JWT_SECRET, SEED_USER_EMAIL, SEED_USER_PASSWORD in .env

make docker-full
# or: docker-compose up --build
```

---

## Running Tests

Integration tests use [testcontainers-go](https://golang.testcontainers.org) to spin up real Postgres and Redis containers — Docker must be running.

```bash
# All tests
make test

# Unit tests only (no Docker needed)
go test ./internal/auth/... ./internal/domain/reminder/... -v
```

---

## API Reference

### Conventions

- **Base URL**: `http://localhost:8080/v1`
- **Auth**: Every request except `/v1/healthz` and `/v1/auth/login` requires `Authorization: Bearer <token>`
- **Content-Type**: `application/json` for all request bodies
- **Money**: All amounts are `int64` **paisa** (BDT). 1 BDT = 100 paisa. The client formats for display.
- **Time**: UTC, RFC3339 (`2026-05-15T12:00:00Z`). Date filters accept `YYYY-MM-DD`.
- **Pagination**: Cursor-based on `(occurred_at DESC, id DESC)`. Pass the `next_cursor` from one response as `cursor=` in the next request.

---

### Auth

#### `POST /v1/auth/login`

Exchange credentials for a JWT. The token is valid for 30 days.

**Request**
```json
{
  "email": "you@example.com",
  "password": "yourpassword"
}
```

**Response `200`**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2026-06-14T10:00:00Z"
}
```

**Response `401`**
```json
{ "error": { "code": "invalid_credentials", "message": "invalid email or password" } }
```

---

### Buckets

Buckets are money containers: wallet, bKash account, bank account, DPS, etc.

#### `GET /v1/buckets`

Returns all non-archived buckets.

**Response `200`**
```json
{
  "items": [
    {
      "id": "01924d2a-...",
      "user_id": "...",
      "name": "bKash",
      "starting_balance_paisa": 500000,
      "created_at": "2026-05-01T00:00:00Z"
    }
  ]
}
```

#### `POST /v1/buckets`

**Request**
```json
{
  "name": "bKash",
  "starting_balance_paisa": 500000
}
```
`starting_balance_paisa` defaults to `0`.

**Response `201`** — the created bucket object.

#### `PATCH /v1/buckets/:id`

Rename or archive a bucket. All fields are optional; omitted fields are unchanged.

**Request**
```json
{
  "name": "bKash Personal",
  "archived": true
}
```

Set `"archived": false` to un-archive.

**Response `200`** — the updated bucket object.

---

### People

People are contacts used as the other party in loan and repayment transactions.

#### `GET /v1/people`

**Response `200`**
```json
{
  "items": [
    { "id": "...", "user_id": "...", "name": "Karim", "created_at": "..." }
  ]
}
```

#### `POST /v1/people`

```json
{ "name": "Karim" }
```

**Response `201`** — the created person object.

#### `PATCH /v1/people/:id`

```json
{ "name": "Karim Hossain", "archived": false }
```

**Response `200`** — the updated person object.

---

### Tags

Tags are free-form labels for categorising transactions: `food`, `family`, `emergency`, etc. Case-insensitive — you cannot create both `Food` and `food`.

#### `GET /v1/tags`

Returns all non-archived tags sorted by most recently used (last transaction date), then creation date. The Android client filters locally; this endpoint always returns the full list.

**Response `200`**
```json
{
  "items": [
    { "id": "...", "user_id": "...", "name": "food", "created_at": "..." }
  ]
}
```

#### `POST /v1/tags`

```json
{ "name": "food" }
```

**Response `201`** — the created tag object.

#### `PATCH /v1/tags/:id`

```json
{ "name": "groceries", "archived": false }
```

**Response `200`** — the updated tag object.

---

### Transactions

The core of the API. Every money movement is a transaction. The ledger is **append-only** — rows are never updated or deleted. Edits insert a reversal row and a new corrected row; deletes insert a reversal row only.

#### Transaction Types

| Type | `from_bucket` | `to_bucket` | `person` |
|---|---|---|---|
| `expense` | required | — | optional |
| `income` | — | required | optional |
| `transfer` | required | required (≠ from) | — |
| `loan_given` | required | — | required |
| `loan_taken` | — | required | required |
| `repayment_received` | — | required | required |
| `repayment_paid` | required | — | required |

#### `GET /v1/transactions`

List live transactions (reversed ones are excluded). Results are paginated with cursor-based pagination, ordered by `occurred_at DESC`.

**Query parameters**

| Parameter | Type | Description |
|---|---|---|
| `type` | string | Filter by transaction type, e.g. `expense` |
| `bucket_id` | UUID | Filter where `from_bucket_id` or `to_bucket_id` matches |
| `person_id` | UUID | Filter by person |
| `tag_id` | UUID | Filter transactions that have this tag |
| `from` | `YYYY-MM-DD` | Earliest `occurred_at` (inclusive) |
| `to` | `YYYY-MM-DD` | Latest `occurred_at` (inclusive, end of day) |
| `limit` | int | Items per page (default `50`, max `200`) |
| `cursor` | string | Opaque cursor from a previous response's `next_cursor` |

**Response `200`**
```json
{
  "items": [
    {
      "id": "01924d2a-...",
      "user_id": "...",
      "type": "expense",
      "amount_paisa": 25000,
      "from_bucket_id": "...",
      "to_bucket_id": null,
      "person_id": null,
      "note": "Lunch at office",
      "occurred_at": "2026-05-14T12:30:00Z",
      "created_at": "2026-05-14T12:31:00Z",
      "tags": [{ "id": "...", "name": "food" }],
      "reversed": false
    }
  ],
  "next_cursor": "eyJ0IjoiMjAyNi0wNS0xNFQxMjozMDowMFoiLCJpIjoiMDE5MjRkMmEtLi4uIn0="
}
```

`next_cursor` is absent or empty when there are no more pages.

#### `POST /v1/transactions`

**Request**
```json
{
  "type": "expense",
  "amount_paisa": 25000,
  "from_bucket_id": "01924d2a-...",
  "to_bucket_id": null,
  "person_id": null,
  "note": "Lunch at office",
  "occurred_at": "2026-05-14T12:30:00Z",
  "tag_ids": ["01924abc-...", "01924def-..."]
}
```

- `amount_paisa` must be > 0.
- `occurred_at` is required (RFC3339).
- `tag_ids` may be an empty array.

**Response `201`** — the created transaction object.

#### `PATCH /v1/transactions/:id`

Correct an existing transaction. Internally: inserts a reversal of the original, then inserts a new row with the corrected data. The original row is never touched.

**Request** — same shape as `POST /v1/transactions`.

**Response `200`** — the new (corrected) transaction object.

#### `DELETE /v1/transactions/:id`

Soft-delete by inserting a reversal row. The original row is never touched.

**Response `204`** — no body.

---

### Reports

All four report endpoints are served from Redis when the cache is warm (TTL: 1 hour for balances and summaries, 15 minutes for tag totals). On cache miss they compute from Postgres and populate the cache. Redis failures are transparent — the API falls back to Postgres and continues normally.

#### `GET /v1/reports/bucket-balances`

Live balance for every non-archived bucket: starting balance plus all credits minus all debits.

**Response `200`**
```json
{
  "items": [
    { "bucket_id": "...", "name": "bKash", "balance_paisa": 1234500 },
    { "bucket_id": "...", "name": "Cash",  "balance_paisa": 87600  }
  ]
}
```

#### `GET /v1/reports/person-balances`

Net position per person across all loan and repayment transactions.

- Positive `net_paisa`: they owe you money (you gave more than they repaid).
- Negative `net_paisa`: you owe them money (they gave more than you repaid).

**Response `200`**
```json
{
  "items": [
    { "person_id": "...", "name": "Karim", "net_paisa": 500000 }
  ]
}
```

#### `GET /v1/reports/tag-totals`

Total expense paisa per tag for a date range. Only `expense` type transactions are counted.

**Query parameters** — both required:

| Parameter | Type | Description |
|---|---|---|
| `from` | `YYYY-MM-DD` | Start of range (inclusive) |
| `to` | `YYYY-MM-DD` | End of range (inclusive) |

**Response `200`**
```json
{
  "items": [
    { "tag_id": "...", "name": "food",      "total_paisa": 320000 },
    { "tag_id": "...", "name": "transport", "total_paisa": 85000  }
  ]
}
```

#### `GET /v1/reports/summary`

Monthly income, expense, and net, plus a per-tag expense breakdown for that month.

**Query parameters**

| Parameter | Type | Description |
|---|---|---|
| `month` | `YYYY-MM` | Month to summarise (defaults to current month) |

**Response `200`**
```json
{
  "income_paisa":  150000,
  "expense_paisa": 98000,
  "net_paisa":     52000,
  "by_tag": [
    { "tag_id": "...", "name": "food", "total_paisa": 45000 }
  ]
}
```

---

### Reminders

Reminders prompt you to pay recurring bills (DPS, rent, subscriptions). Paying a reminder auto-creates a transaction and advances the due date according to the recurrence rule.

#### Recurrence types

| `recurrence_type` | Behaviour |
|---|---|
| `none` | One-time. Status becomes `completed` after pay or skip. |
| `weekly` | Advances by 7 days. |
| `monthly` | Advances by 1 calendar month, clamped to the last day of the next month. |
| `yearly` | Advances by 1 year. |

For `monthly` with a `recurrence_day` (e.g. `31`), the day is clamped to the last day of the target month (e.g. Feb → 28 or 29).

#### `GET /v1/reminders`

**Query parameters**

| Parameter | Type | Description |
|---|---|---|
| `due_before` | RFC3339 or `YYYY-MM-DD` | Only return reminders due before this date |

Returns only `active` reminders.

**Response `200`**
```json
{
  "items": [
    {
      "id": "...",
      "user_id": "...",
      "title": "DPS",
      "amount_paisa": 500000,
      "default_type": "expense",
      "recurrence_type": "monthly",
      "recurrence_day": 1,
      "next_due_at": "2026-06-01T09:00:00Z",
      "linked_bucket_id": "...",
      "linked_person_id": null,
      "status": "active",
      "created_at": "..."
    }
  ]
}
```

#### `POST /v1/reminders`

**Request**
```json
{
  "title": "DPS",
  "amount_paisa": 500000,
  "default_type": "expense",
  "recurrence_type": "monthly",
  "recurrence_day": 1,
  "next_due_at": "2026-06-01T09:00:00Z",
  "linked_bucket_id": "...",
  "linked_person_id": null,
  "tag_ids": []
}
```

- `title`, `default_type`, `recurrence_type`, and `next_due_at` are required.
- `amount_paisa` is optional — you can set it later or override it at pay time.
- `linked_bucket_id` and `linked_person_id` are used when auto-creating the transaction on pay.

**Response `201`** — the created reminder object.

#### `PATCH /v1/reminders/:id`

Update any field. All fields are optional.

```json
{
  "title": "DPS (updated)",
  "amount_paisa": 600000,
  "status": "paused"
}
```

**Response `200`** — the updated reminder.

#### `POST /v1/reminders/:id/pay`

Creates a transaction using the reminder's defaults (overridden by the request body) and advances `next_due_at`. A `none` recurrence reminder transitions to `completed`.

**Request** — all fields optional, fall back to reminder defaults:
```json
{
  "amount_paisa": 500000,
  "occurred_at": "2026-06-01T09:00:00Z",
  "note": "DPS for June"
}
```

If `amount_paisa` is not set here and is also not set on the reminder, the request fails with a `400 validation_error`.

**Response `200`**
```json
{
  "reminder": { "...updated reminder..." },
  "transaction": { "...created transaction..." }
}
```

#### `POST /v1/reminders/:id/skip`

Advances `next_due_at` without creating a transaction. A `none` recurrence reminder transitions to `completed`.

**Response `200`** — the updated reminder.

---

## Error Reference

All errors have this envelope:

```json
{
  "error": {
    "code": "validation_error",
    "message": "transaction field validation failed",
    "fields": {
      "from_bucket_id": "required for expense",
      "amount_paisa": "must be > 0"
    }
  }
}
```

`fields` is only present on `validation_error`.

| Code | HTTP Status | When |
|---|---|---|
| `invalid_credentials` | 401 | Wrong email or password |
| `forbidden` | 401 | Missing or invalid JWT |
| `validation_error` | 400 | Request body fails validation |
| `not_found` | 404 | Resource does not exist or belongs to a different user |
| `conflict` | 409 | Operation not allowed (e.g. reversing an already-reversed transaction) |
| `internal_error` | 500 | Unexpected server error |

---

## Data Model

```
users
  id               UUID PK
  email            TEXT UNIQUE
  password_hash    TEXT          -- bcrypt
  created_at       TIMESTAMPTZ

buckets
  id               UUID PK
  user_id          UUID → users
  name             TEXT
  starting_balance BIGINT        -- paisa
  archived_at      TIMESTAMPTZ   -- NULL = active

people
  id, user_id, name, archived_at, created_at

tags
  id, user_id, name, archived_at, created_at
  UNIQUE INDEX (user_id, LOWER(name))   -- case-insensitive

transactions                            ← append-only, never UPDATE/DELETE
  id               UUID PK
  user_id          UUID → users
  type             TEXT  CHECK (type IN (expense|income|transfer|
                                         loan_given|loan_taken|
                                         repayment_received|repayment_paid))
  amount           BIGINT > 0          -- paisa
  from_bucket_id   UUID → buckets      -- nullable
  to_bucket_id     UUID → buckets      -- nullable
  person_id        UUID → people       -- nullable
  note             TEXT
  occurred_at      TIMESTAMPTZ
  created_at       TIMESTAMPTZ
  reverses_id      UUID → transactions -- non-null on reversal rows

transaction_tags
  transaction_id, tag_id               -- many-to-many

reminders
  id, user_id, title
  amount           BIGINT              -- paisa, nullable
  default_type     TEXT                -- transaction type to create on pay
  recurrence_type  TEXT  CHECK (none|weekly|monthly|yearly)
  recurrence_day   INT                 -- nullable, day-of-month for monthly
  next_due_at      TIMESTAMPTZ
  linked_bucket_id UUID → buckets      -- nullable
  linked_person_id UUID → people       -- nullable
  status           TEXT  CHECK (active|paused|completed)
  created_at       TIMESTAMPTZ

reminder_tags
  reminder_id, tag_id
```

### How the append-only ledger works

Every write is an **insert only**. The `reverses_id` column is the key:

```
PATCH /v1/transactions/A (correct the amount)
  → INSERT row B with reverses_id = A   (reversal of A)
  → INSERT row C with no reverses_id    (new corrected row)

DELETE /v1/transactions/A
  → INSERT row B with reverses_id = A   (reversal of A)
```

`GET /v1/transactions` returns rows that have no `reverses_id` (they are not reversals) **and** no other row points to them via `reverses_id` (they have not been reversed). This gives the live view.

### Balance computation

**Bucket balance** = `starting_balance` + sum of credits to bucket − sum of debits from bucket, across all live transactions.

**Person net** = sum of `loan_given` + `repayment_received` − sum of `loan_taken` − `repayment_paid`, across all live transactions for that person.

---

## Architecture

```
cmd/server/main.go
  └─ loads config, runs migrations, seeds user, wires dependencies, starts HTTP server

internal/
  config/          env loading + validation
  platform/
    logger/        slog (text in dev, JSON in production)
    apperror/      typed errors + HTTP status mapping + JSON envelope renderer
    money/         paisa helpers (formatting only — no arithmetic in this layer)
  db/
    migrations/    *.up.sql / *.down.sql (never edit old migrations)
    queries/       *.sql source files consumed by sqlc
    sqlc/          generated Go (do not edit by hand)
    db.go          pgxpool setup
    migrate.go     golang-migrate runner + user seeder
  cache/           Redis wrapper — fail-open; all methods log warnings on error
  auth/            bcrypt, JWT sign/parse, RequireAuth middleware
  domain/
    bucket/        CRUD service
    person/        CRUD service
    tag/           CRUD service (case-insensitive dedup)
    transaction/   Create / List / Update / Delete with append-only logic
    report/        Read-through cache for aggregates
    reminder/      Create / List / Pay / Skip with recurrence math
  http/
    middleware/     Recover, RequestID, Logging
    handlers/       One file per domain; thin — delegates to domain services
    server.go       chi router wiring
  testutil/        Shared testcontainers helper (Postgres + Redis per test)
```

### Request lifecycle

```
request
  → Recover (panic → 500)
  → RequestID (X-Request-ID header)
  → Logging (method, path, status, duration_ms)
  → RequireAuth (JWT → user_id in context)  ← skipped for /healthz and /auth/login
  → handler
      → decode + validate input
      → call domain service
          → (for writes) open pgx transaction, insert, commit, invalidate cache
          → (for reads)  check Redis, fall back to Postgres, populate cache
      → write JSON response
```

### Cache invalidation

When any transaction is created, updated, or deleted for a user, the following cache keys are deleted atomically:

```
DEL  bal:bucket:{user_id}
DEL  bal:person:{user_id}
SCAN + DEL  tagtot:{user_id}:*
SCAN + DEL  summary:{user_id}:*
```

Archiving a bucket or person also deletes the corresponding balance key.

Cache failures are logged as warnings but never returned as errors — the API always falls back to computing from Postgres.

---

## Development Guide

### Making schema changes

1. Create a new migration file — never edit existing ones:
   ```bash
   # Example: add a column
   touch internal/db/migrations/0003_add_currency.up.sql
   touch internal/db/migrations/0003_add_currency.down.sql
   ```
2. Write the SQL.
3. Regenerate sqlc if you changed a table used by queries:
   ```bash
   make sqlc
   ```
4. The server auto-runs migrations on startup (`RunMigrations`).

### Updating SQL queries

1. Edit the relevant file in `internal/db/queries/`.
2. Run `make sqlc` to regenerate `internal/db/sqlc/`.
3. The generated files in `internal/db/sqlc/` are never edited by hand.

### Regenerating sqlc

```bash
make sqlc
# or: sqlc generate
```

**Notes**:
- sqlc is configured with `sql_package: "pgx/v5"` — the generated `DBTX` interface uses `Exec/Query/QueryRow` (not `ExecContext`). Some IDE/LSP tools may show stale errors; trust `go build` over the LSP.
- For aggregate queries returning `SUM(bigint)`, always use `CAST(... AS BIGINT)` explicitly — sqlc infers `int32` from uncast `SUM` expressions.
- Nullable text filter parameters (`$2::text IS NULL OR t.col = $2`) generate `string`, not a nullable type. Use `$2 = '' OR t.col = $2` instead and pass empty string to mean "no filter".

### Adding a new domain

1. Create `internal/domain/<name>/service.go`.
2. Add SQL queries to `internal/db/queries/<name>.sql`, run `make sqlc`.
3. Add handler to `internal/http/handlers/<name>.go`.
4. Wire routes in `internal/http/server.go`.
5. Write integration tests in `internal/domain/<name>/<name>_test.go` using `testutil.NewTestDB(t)`.

### Makefile targets

| Target | Description |
|---|---|
| `make run` | Run the server with `.env` loaded |
| `make build` | Compile to `bin/server` |
| `make test` | Run all tests (requires Docker) |
| `make sqlc` | Regenerate `internal/db/sqlc/` from SQL |
| `make migrate-up` | Apply pending migrations manually |
| `make migrate-down` | Roll back the last migration |
| `make lint` | Run `golangci-lint` |
| `make docker-up` | Start Postgres + Redis containers |
| `make docker-down` | Stop and remove containers |
| `make docker-full` | Build and start the full stack |
