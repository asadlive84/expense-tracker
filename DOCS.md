# Expense Tracker — Complete Project Documentation

> **Developer:** Asaduzzaman Sohel · [@asadlive84](https://x.com/asadlive84) · asadlive.sohel@gmail.com

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Repository Structure](#2-repository-structure)
3. [Backend API (Go)](#3-backend-api-go)
4. [Web Frontend (React)](#4-web-frontend-react)
5. [Mobile App (Flutter)](#5-mobile-app-flutter)
6. [Environment Variables](#6-environment-variables)
7. [Running Everything Locally](#7-running-everything-locally)
8. [Building for Production](#8-building-for-production)
9. [API Reference](#9-api-reference)
10. [Database Schema](#10-database-schema)
11. [Architecture Decisions](#11-architecture-decisions)

---

## 1. Project Overview

A full-stack personal finance tracker with three clients:

| Layer | Technology | Purpose |
|---|---|---|
| **Backend** | Go 1.25 | REST API, PostgreSQL, Redis cache |
| **Web Frontend** | React 19 + TypeScript | Browser-based dashboard |
| **Mobile App** | Flutter 3 | Android app (published to Play Store) |

**Core features:**
- Track money across multiple buckets (Cash, bKash, Bank, DPS, etc.)
- Append-only ledger — transactions are never deleted, only reversed
- Loans and repayments between contacts
- Tag-based spending categorisation
- Recurring payment reminders (weekly / monthly / yearly)
- Live balance reports with Redis caching
- Offline detection + server-down detection in mobile app

---

## 2. Repository Structure

```
expense-tracker/
├── cmd/server/main.go          # Go server entry point
├── internal/                   # All Go source code
│   ├── auth/                   # JWT, bcrypt, auth middleware
│   ├── cache/                  # Redis wrapper
│   ├── config/                 # Env var loading
│   ├── db/
│   │   ├── migrations/         # SQL migration files (*.up.sql / *.down.sql)
│   │   ├── queries/            # SQL queries consumed by sqlc
│   │   └── sqlc/               # Generated Go code — do not edit
│   ├── domain/                 # Business logic
│   │   ├── bucket/
│   │   ├── person/
│   │   ├── tag/
│   │   ├── transaction/        # Append-only ledger core
│   │   ├── reminder/
│   │   └── report/             # Cached aggregates
│   ├── http/                   # HTTP handlers, router, middleware
│   └── platform/               # Logger, errors, money helpers
├── frontend/                   # React web app
│   └── src/
│       ├── api/                # Axios API client (one file per domain)
│       ├── components/         # Reusable UI components
│       ├── hooks/              # TanStack Query hooks
│       ├── pages/              # Route-level screens
│       └── utils/              # money.ts, date.ts, errors.ts
├── mobile_app/                 # Flutter Android app
│   └── lib/
│       ├── core/               # API client, auth, storage, theme
│       ├── features/           # Feature modules (auth, buckets, etc.)
│       └── shared/             # Shared models, widgets, constants
├── openapi.yaml                # OpenAPI 3.0 spec — source of truth for API
├── sqlc.yaml                   # sqlc code generation config
├── docker-compose.yml          # Local dev (Postgres + Redis + API)
├── Dockerfile                  # Multi-stage Go build
└── Makefile                    # Common dev commands
```

---

## 3. Backend API (Go)

### Stack

- **Language:** Go 1.25
- **Router:** `go-chi/chi v5`
- **Database:** PostgreSQL 16 via `pgx/v5` + `pgxpool`
- **Query generation:** `sqlc` (pgx native mode — no ORM)
- **Migrations:** `golang-migrate/migrate v4`
- **Cache:** Redis 7 via `go-redis/v9`
- **Auth:** JWT HS256 via `golang-jwt/jwt v5` + bcrypt
- **Validation:** `go-playground/validator v10`

### Key Design Principles

**Append-only ledger**
The `transactions` table is never `UPDATE`d or `DELETE`d. Corrections insert a reversal row (setting `reverses_id` to point at the original) plus a new corrected row. The list endpoint filters out any row that has been reversed.

**Redis cache-aside**
Reports (bucket balances, person balances, tag totals, monthly summary) are served from Redis with TTLs of 15 min–1 hour. On any transaction write, all four key groups are invalidated. Redis failures never break the API — it falls back to Postgres silently.

**Single user**
No signup endpoint. One user is seeded at startup from `SEED_USER_EMAIL` and `SEED_USER_PASSWORD` env vars. The password is bcrypt-hashed on first run.

### Running the backend

```bash
# Start Postgres + Redis
make docker-up

# Run migrations + start server
make run
```

### Running tests

```bash
make test
# Requires Docker — testcontainers spins up real Postgres + Redis per test
```

### Adding a migration

```bash
# Create new migration files (never edit existing ones)
touch internal/db/migrations/0004_my_change.up.sql
touch internal/db/migrations/0004_my_change.down.sql

# Edit the SQL, then regenerate sqlc if queries changed
make sqlc
```

### Regenerating sqlc

```bash
make sqlc
# or: sqlc generate
```

> The generated files in `internal/db/sqlc/` must never be edited by hand.

---

## 4. Web Frontend (React)

### Stack

- **Framework:** React 19 + TypeScript
- **Build:** Vite 8
- **Styling:** Tailwind CSS v4
- **State/data:** TanStack Query v5
- **HTTP:** Axios (with JWT interceptor)
- **Routing:** React Router v7
- **Forms:** React Hook Form + Zod
- **Charts:** Recharts
- **Animations:** Framer Motion

### Key Performance Patterns

- **Optimistic updates** on every mutation — UI updates before the server responds
- **Skeleton screens** on first load, stale data shown instantly on revisit
- **Infinite scroll** on the transaction list (`IntersectionObserver`, 200px lookahead)
- **Hover prefetching** on nav links and list items
- **Framer Motion** list animations on add/delete
- **Parallel API calls** on the dashboard (4 fetches at once, no waterfall)

### Running the frontend

```bash
cd frontend
npm install
npm run dev        # http://localhost:5173
```

### Building for production

```bash
cd frontend
npm run build      # Output: frontend/dist/
```

### Environment

```bash
# frontend/.env
VITE_API_BASE_URL=http://localhost:8080/v1
```

### Pages

| Route | Screen |
|---|---|
| `/login` | Login with email + password |
| `/register` | Register (name, email, phone, password) |
| `/` | Dashboard — balance cards, recent transactions, upcoming reminders |
| `/transactions` | Full ledger with filters + infinite scroll |
| `/buckets` | Bucket management with live balances |
| `/people` | People management with net loan balances |
| `/tags` | Tag management with monthly spend totals |
| `/reports` | Charts — income/expense bar, tag donut, bucket bars |
| `/reminders` | Recurring payment reminders |

---

## 5. Mobile App (Flutter)

### Stack

- **Framework:** Flutter 3 / Dart 3
- **State:** Riverpod 2 (`AsyncNotifierProvider`, `FutureProvider.family`)
- **HTTP:** Dio 5 with interceptors
- **Models:** Freezed + json_serializable (code generated)
- **Routing:** GoRouter 13
- **Charts:** fl_chart
- **Storage:** flutter_secure_storage (JWT), SharedPreferences (user name)
- **Connectivity:** connectivity_plus

### Building the APK

```bash
cd ~/go/src/expense-tracker/mobile_app && \
flutter build apk --release && \
cp build/app/outputs/flutter-apk/app-release.apk ../expenseTracker.apk
```

Output: `~/go/src/expense-tracker/expenseTracker.apk`

### With a custom API server

```bash
cd ~/go/src/expense-tracker/mobile_app && \
flutter build apk --release \
  --dart-define=API_BASE_URL=http://YOUR_SERVER/v1 && \
cp build/app/outputs/flutter-apk/app-release.apk ../expenseTracker.apk
```

### Regenerating Freezed models

When `lib/shared/models/models.dart` or `lib/features/auth/data/auth_models.dart` are changed:

```bash
cd mobile_app
flutter pub run build_runner build --delete-conflicting-outputs
```

### App Screens

| Screen | Notes |
|---|---|
| Splash | Shows "Expense Tracker" + icon, checks saved JWT |
| Login | Email + password, syncs name/phone from server |
| Register | Name, phone (optional), email, password |
| Home | Greeting, net worth card, income/expense, upcoming reminders |
| Ledger | Transaction list, swipe-to-delete, filters, type icons |
| Insights | Dynamic period selector, bar chart (6 months), donut chart by tag, bucket bars, people balances |
| Reminders | Overdue / due soon / upcoming groups, pay + skip |
| Settings | Edit profile (name + phone synced to server), theme, report issue, sign out |
| Buckets | Live balances, create/rename/archive |
| People | Net loan balance display, create/rename/archive |
| Tags | Monthly totals, create/rename/archive |
| About | Developer contact — Asaduzzaman Sohel, @asadlive84 |

### Offline / Server-down handling

- **No internet** → orange Wi-Fi-off overlay, auto-recovers when connection returns
- **Server down** → red cloud-off overlay, retries `/healthz` every 15 seconds automatically, "Report this issue" button pre-fills an email

### Known: app.dart placement

`NoInternetWrapper` must be used **inside** `MaterialApp.builder`, not wrapping `MaterialApp` from outside. Placing it outside causes `No Directionality widget found` crash because it renders before `MaterialApp` provides `Theme` and `Directionality`.

```dart
// ✅ Correct
MaterialApp.router(
  builder: (context, child) => NoInternetWrapper(child: child!),
  ...
)

// ❌ Wrong — crashes with No Directionality
NoInternetWrapper(
  child: MaterialApp.router(...),
)
```

---

## 6. Environment Variables

### Backend

| Variable | Required | Default | Description |
|---|---|---|---|
| `DATABASE_URL` | Yes | — | `postgres://user:pass@host:5432/db?sslmode=disable` |
| `REDIS_URL` | No | `redis://localhost:6379` | Redis connection string |
| `JWT_SECRET` | Yes | — | HS256 signing key, minimum 32 characters |
| `SEED_USER_EMAIL` | Yes | — | Email for the single user account |
| `SEED_USER_PASSWORD` | Yes | — | Plaintext password (bcrypt-hashed on startup) |
| `PORT` | No | `8080` | HTTP listen port |
| `MIGRATIONS_PATH` | No | `internal/db/migrations` | Path to `.sql` migration files |
| `ENV` | No | — | Set to `production` for JSON logs |

### Frontend

| Variable | Default | Description |
|---|---|---|
| `VITE_API_BASE_URL` | `http://localhost:8080/v1` | Backend base URL |

### Mobile App

| Dart define | Default | Description |
|---|---|---|
| `API_BASE_URL` | `http://18.139.46.170/v1` | Backend base URL |

Set with `--dart-define=API_BASE_URL=https://your-server/v1` at build time.

---

## 7. Running Everything Locally

### 1. Start infrastructure

```bash
make docker-up
# Starts Postgres 16 on :5432 and Redis 7 on :6379
```

### 2. Configure environment

```bash
cp .env.example .env
# Edit .env — set JWT_SECRET, SEED_USER_EMAIL, SEED_USER_PASSWORD
```

### 3. Start the backend

```bash
make run
# Runs migrations, seeds user, starts API on :8080
```

### 4. Start the web frontend

```bash
cd frontend
cp .env.example .env      # set VITE_API_BASE_URL=http://localhost:8080/v1
npm install
npm run dev               # http://localhost:5173
```

### 5. Run the mobile app

```bash
cd mobile_app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/v1
# Note: 10.0.2.2 is the Android emulator's alias for host localhost
```

### Full stack with Docker Compose

```bash
cp .env.example .env      # fill in secrets
docker-compose up --build # builds and starts API + Postgres + Redis
```

---

## 8. Building for Production

### Backend Docker image

```bash
docker build -t expense-tracker-api .
docker run -p 8080:8080 --env-file .env expense-tracker-api
```

### Frontend static build

```bash
cd frontend
npm run build
# Serve the dist/ folder with nginx, Caddy, or any static host
```

### Android APK (release)

```bash
cd ~/go/src/expense-tracker/mobile_app && \
flutter build apk --release \
  --dart-define=API_BASE_URL=https://your-production-server/v1 && \
cp build/app/outputs/flutter-apk/app-release.apk ../expenseTracker.apk
```

### Android App Bundle (for Play Store)

```bash
cd ~/go/src/expense-tracker/mobile_app && \
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://your-production-server/v1
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## 9. API Reference

The complete machine-readable API contract is in **`openapi.yaml`** at the repository root.

Import it into:
- **Postman** — Import → OpenAPI 3.0
- **Swagger UI** — `npx @stoplight/elements-cli preview openapi.yaml`
- **Insomnia** — Import → From File

### Quick endpoint summary

```
POST   /v1/auth/login          Login → token + user profile
POST   /v1/auth/register       Register (name, phone optional) → token
GET    /v1/me                  Get profile (id, email, name, phone)
PATCH  /v1/me                  Update name and/or phone

GET    /v1/buckets             List active buckets
POST   /v1/buckets             Create bucket
PATCH  /v1/buckets/:id         Rename / archive

GET    /v1/people              List active people
POST   /v1/people              Create person
PATCH  /v1/people/:id          Rename / archive

GET    /v1/tags                List active tags (sorted by recent use)
POST   /v1/tags                Create tag
PATCH  /v1/tags/:id            Rename / archive

GET    /v1/transactions        List (filters: type, bucket, person, tag, from, to) + cursor pagination
POST   /v1/transactions        Create transaction
PATCH  /v1/transactions/:id    Correct transaction (inserts reversal + new row)
DELETE /v1/transactions/:id    Delete transaction (inserts reversal only) → 204

GET    /v1/reports/bucket-balances          Live bucket balances (Redis cached 1h)
GET    /v1/reports/person-balances          Net loan balance per person (Redis 1h)
GET    /v1/reports/tag-totals?from=&to=     Tag expense totals (Redis 15min)
GET    /v1/reports/summary?month=YYYY-MM    Monthly income/expense/net (Redis 1h)

GET    /v1/reminders           List active reminders
POST   /v1/reminders           Create reminder
PATCH  /v1/reminders/:id       Update reminder
POST   /v1/reminders/:id/pay   Pay → creates transaction + advances due date
POST   /v1/reminders/:id/skip  Skip → advances due date only

GET    /v1/healthz             Health check (no auth required)
```

### Transaction types

| Type | from_bucket | to_bucket | person |
|---|---|---|---|
| `expense` | required | — | optional |
| `income` | — | required | optional |
| `transfer` | required | required (≠ from) | — |
| `loan_given` | required | — | required |
| `loan_taken` | — | required | required |
| `repayment_received` | — | required | required |
| `repayment_paid` | required | — | required |

### Error envelope

Every error response has this shape:

```json
{
  "error": {
    "code": "validation_error",
    "message": "human readable description",
    "fields": {
      "amount_paisa": "must be > 0"
    }
  }
}
```

`fields` is only present for `validation_error`.

| Code | HTTP | When |
|---|---|---|
| `invalid_credentials` | 401 | Wrong email or password |
| `forbidden` | 401 | Missing or invalid JWT |
| `validation_error` | 400 | Request body fails validation |
| `not_found` | 404 | Resource not found |
| `conflict` | 409 | e.g. reversing an already-reversed transaction |
| `internal_error` | 500 | Unexpected server error |

### Money

All amounts are **`int64` paisa**. 1 BDT = 100 paisa. Never floats.

```
25000 paisa = ৳250.00
```

The client is responsible for formatting. The API never returns BDT strings.

---

## 10. Database Schema

### Tables

| Table | Purpose |
|---|---|
| `users` | Single user account. Has `name` and `phone` optional fields. |
| `buckets` | Money containers (Cash, bKash, Bank, DPS, etc.) |
| `people` | Contacts for loan/repayment transactions |
| `tags` | Free-form spending labels |
| `transactions` | **Append-only ledger** — never updated or deleted |
| `transaction_tags` | Many-to-many link between transactions and tags |
| `reminders` | Recurring payment reminders |
| `reminder_tags` | Many-to-many link between reminders and tags |

### Migrations

| File | Description |
|---|---|
| `0001_init.up.sql` | Creates all tables and indexes |
| `0002_seed_user.up.sql` | No-op placeholder (user seeded by Go at startup) |
| `0003_user_profile.up.sql` | Adds `name` and `phone` columns to `users` |

### How the append-only ledger works

```
Original transaction A: expense ৳100

User edits A → amount becomes ৳200:
  INSERT row B  (reverses_id = A)   ← cancels A
  INSERT row C  (no reverses_id)    ← new corrected row

GET /v1/transactions returns: C only
  A is excluded because B points to it (it has been reversed)
  B is excluded because reverses_id IS NOT NULL (it's a reversal row)
```

---

## 11. Architecture Decisions

### Why append-only transactions?

An auditable ledger. No record of any financial movement is ever destroyed. This is the same approach used by accounting systems and banks — every correction leaves a paper trail. It also makes the Redis cache invalidation simple: any write clears the cache.

### Why sqlc instead of an ORM?

sqlc generates type-safe Go from hand-written SQL. The SQL is readable, the generated Go is deterministic, and there's no magic. ORM query abstractions tend to generate suboptimal SQL and hide what's actually being sent to the database.

### Why Redis for reports only, not raw entities?

Raw entities (buckets, transactions) are cheap to fetch by ID with indexes. The expensive operations are aggregations — summing thousands of transaction rows to compute a balance. Those are the only things cached. This keeps the cache small, easy to invalidate, and correct.

### Why a single user?

This is a personal finance app. Multi-tenancy would add complexity (row-level security, billing, invite flows) with no benefit for the intended use case. The schema is designed for multi-user (every row has a `user_id`) so it could be extended later without a migration.

### Why Flutter for mobile?

Single codebase compiles to Android (and iOS). Riverpod provides fine-grained reactive state without rebuilding the entire widget tree. Freezed generates immutable, equality-correct model classes from a single declaration.

---

## Contact & Support

**Developer:** Asaduzzaman Sohel
**Email:** asadlive.sohel@gmail.com
**Social:** [@asadlive84](https://x.com/asadlive84)

To report a bug, email with subject **"Expense Tracker – Bug Report"** or use the **Report an Issue** button inside the app (Settings → Report an Issue).
