# Expense Tracker — Developer Journal & Troubleshooting Guide

Complete record of everything built, every bug hit, and every fix applied.
Use this as a reference for future development, debugging, or onboarding.

---

## Table of Contents

1. [Project Architecture](#1-project-architecture)
2. [Backend (Go API)](#2-backend-go-api)
3. [Frontend (React)](#3-frontend-react)
4. [Mobile App (Flutter)](#4-mobile-app-flutter)
5. [Deployment & Infrastructure](#5-deployment--infrastructure)
6. [Database Access & Debugging](#6-database-access--debugging)
7. [All Bugs & Fixes](#7-all-bugs--fixes)
8. [Localization (Bangla / English)](#8-localization-bangla--english)
9. [Cheatsheet — Daily Dev Commands](#9-cheatsheet--daily-dev-commands)

---

## 1. Project Architecture

```
expense-tracker/
├── cmd/                        # Go main entrypoint
├── internal/
│   ├── db/
│   │   ├── migrations/         # SQL migration files (golang-migrate)
│   │   └── queries/            # sqlc query files
│   ├── handlers/               # HTTP handlers per domain
│   ├── middleware/             # JWT auth, CORS, rate-limit
│   ├── models/                 # Domain structs
│   └── services/               # Business logic
├── frontend/                   # React TypeScript SPA
├── mobile_app/                 # Flutter Android app
├── deploy/
│   └── nginx.conf              # Nginx config template (__DOMAIN__ placeholder)
├── docker-compose.yml          # Local development
├── docker-compose.prod.yml     # Production
├── .github/workflows/
│   └── deploy.yml              # Auto-deploy on push to main
└── openapi.yaml                # Full API spec
```

**Tech stack:**
| Layer | Tech |
|---|---|
| Backend | Go, chi router, pgx/v5, sqlc, golang-migrate, go-redis/v9, golang-jwt/v5 |
| Frontend | React, TypeScript, Vite |
| Mobile | Flutter, Riverpod 2, Freezed, GoRouter, Dio 5, fl_chart |
| Database | PostgreSQL 16 |
| Cache | Redis |
| Infra | AWS EC2, Cloudflare (free SSL), Docker, Nginx |

**Production URL:** `https://pocketguard.store`  
**API base:** `https://pocketguard.store/v1`  
**Server IP:** `18.139.46.170`

---

## 2. Backend (Go API)

### Design Decisions

**Append-only ledger** — transactions are never UPDATE'd or DELETE'd.
When a user "deletes" a transaction, a reversal entry is inserted instead.
This preserves full audit history.

**Authentication** — JWT tokens. Refresh token stored in Redis.
Access token: 15 min. Refresh token: 7 days.

**Migrations** — managed by `golang-migrate`. Files in `internal/db/migrations/`.
The app runs migrations automatically on startup.

### Migration files

| File | Purpose |
|---|---|
| `0001_init.up.sql` | All core tables: users, buckets, transactions, tags, etc. |
| `0002_seed_user.up.sql` | Initial seed (if any) |
| `0003_user_profile.up.sql` | Added name + phone columns to users |

### Running locally

```bash
# Start dependencies
docker compose up -d

# Run API
go run ./cmd/...

# Or with make
make run
```

### Environment variables

```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=yourpassword
DB_NAME=expense_tracker
REDIS_URL=redis://localhost:6379
JWT_SECRET=your_jwt_secret
PORT=8080
```

> **Critical:** `REDIS_URL` must include the `redis://` scheme.
> `redis:6379` (no scheme) silently breaks Redis and the app.

---

## 3. Frontend (React)

Single-page app. Runs in Docker behind Nginx in production.

**Port mapping in `docker-compose.prod.yml`:**
```yaml
frontend:
  ports:
    - "127.0.0.1:3000:80"   # NOT 80:80 — Nginx on host owns port 80
```

The host Nginx proxies `/` to `127.0.0.1:3000` and `/v1` to the Go API.

---

## 4. Mobile App (Flutter)

### Architecture

```
mobile_app/lib/
├── app.dart                        # MaterialApp.router root
├── main.dart                       # Startup: loads saved URL + locale
├── core/
│   ├── api/
│   │   ├── api_client.dart         # Dio client, serverUrlProvider
│   │   └── app_error.dart          # UnauthorizedError, NetworkError, ServerError
│   ├── formatters/
│   │   └── date_formatter.dart     # Smart date: "Today 2:02PM", "Sunday 13th May"
│   ├── locale/
│   │   └── locale_provider.dart    # StateProvider<Locale>, save/load from SharedPreferences
│   ├── routing/
│   │   └── app_router.dart         # GoRouter, auth redirect
│   ├── storage/
│   │   └── server_url_storage.dart # Read/write server URL to SharedPreferences
│   └── theme/
│       ├── app_theme.dart          # Light + dark Material3 themes
│       └── theme_controller.dart   # ThemeMode provider
├── features/
│   ├── auth/                       # Login, Register screens
│   ├── dashboard/                  # Home screen with summary cards
│   ├── transactions/               # Ledger list + full transaction form
│   ├── insights/                   # Charts (income vs expense, by category)
│   ├── reminders/                  # Scheduled payment reminders
│   └── settings/                   # Buckets, People, Tags, About, Theme, Language
├── l10n/
│   ├── app_bn.arb                  # Bengali strings (default)
│   └── app_en.arb                  # English strings
└── shared/
    └── widgets/
        └── no_internet_banner.dart # Full-screen overlay when offline/server down
```

### Critical: AndroidManifest.xml

`android/app/src/main/AndroidManifest.xml` **must** have:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

Without `INTERNET` permission, the app silently fails to make any network request.
No error in logs. Just "Cannot reach server."
This was the root cause of all connection failures on the real Samsung device.

### app.dart — NoInternetWrapper placement

`NoInternetWrapper` **must** be inside `MaterialApp.builder`, not outside it:

```dart
// CORRECT
MaterialApp.router(
  builder: (context, child) => NoInternetWrapper(child: child ?? const SizedBox.shrink()),
)

// WRONG — causes "No Directionality widget found" crash
NoInternetWrapper(
  child: MaterialApp.router(...)
)
```

### main.dart startup

Loads saved server URL and locale from SharedPreferences before `runApp`:

```dart
final results = await Future.wait([ServerUrlStorage.read(), loadLocale()]);
runApp(ProviderScope(overrides: [
  serverUrlProvider.overrideWith((ref) => results[0] as String),
  localeProvider.overrideWith((ref) => results[1] as Locale),
], child: const ExpenseTrackerApp()));
```

### Dashboard auto-refresh

After any transaction create/edit/delete, call `_invalidateReports()` in the transactions provider.
Without this, the dashboard summary cards don't update until manual pull-to-refresh.

### Building APK

```bash
cd mobile_app
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Date formatting

`lib/core/formatters/date_formatter.dart`:

| Method | Output |
|---|---|
| `DateFormatter.smart(dt)` | "Today 2:02PM" / "Yesterday 9:15AM" / "13th May 2:02PM" |
| `DateFormatter.full(dt)` | "Sunday 13th May 2:02PM" |
| `DateFormatter.dateOnly(dt)` | "13th May 2026" |

---

## 5. Deployment & Infrastructure

### Server

- AWS EC2 (Ubuntu)
- IP: `18.139.46.170`
- SSH key: `prod-ubntu-expense-tracker.pem`
- Domain: `pocketguard.store` via Cloudflare

### Cloudflare SSL

Cloudflare proxy provides free SSL. No cert management needed.
- DNS A record: `pocketguard.store` → `18.139.46.170` (Proxied = orange cloud ON)
- SSL mode: **Full** (not Full Strict — EC2 has no cert, Cloudflare terminates TLS)

### Auto-deploy (GitHub Actions)

Push to `main` → `.github/workflows/deploy.yml` runs:
1. SSH into EC2
2. `git pull`
3. Write `.env.prod` from GitHub Secrets
4. `docker compose -f docker-compose.prod.yml up -d --build`

**Nginx config:** stored in `deploy/nginx.conf` with `__DOMAIN__` placeholder.
During deploy, `sed` replaces `__DOMAIN__` with the actual domain.
(Heredocs inside YAML cause parse errors — that's why it's a separate file.)

### Production docker-compose key settings

```yaml
db:
  ports:
    - "127.0.0.1:5432:5432"   # Expose to host localhost only (needed for SSH tunnel)

frontend:
  ports:
    - "127.0.0.1:3000:80"     # Not 0.0.0.0:80 — host Nginx owns port 80

api:
  environment:
    REDIS_URL: redis://redis:6379   # Must have redis:// scheme
```

### Manual deploy

```bash
ssh -i prod-ubntu-expense-tracker.pem ubuntu@18.139.46.170
cd ~/expense-tracker
git pull
docker compose -f docker-compose.prod.yml up -d --build
```

---

## 6. Database Access & Debugging

### Connect to production DB from your Mac

**Step 1 — Open SSH tunnel:**

```bash
# Kill any existing tunnel on port 5433
lsof -ti:5433 | xargs kill -9

# Open tunnel
ssh -i ~/Downloads/prod-ubntu-expense-tracker.pem \
    -L 5433:localhost:5432 \
    -fN ubuntu@18.139.46.170
```

> The `-fN` flags run it in the background silently.

**Step 2 — Verify tunnel is working:**

```bash
nc -zv 127.0.0.1 5433
# Should print: Connection to 127.0.0.1 port 5433 succeeded!
```

**Step 3 — Connect DB client (DBeaver / TablePlus):**

| Field | Value |
|---|---|
| Host | `127.0.0.1` |
| Port | `5433` |
| Database | `expense_tracker` |
| User | from `.env.prod` → `DB_USER` |
| Password | from `.env.prod` → `DB_PASSWORD` |

**Find credentials on the server:**

```bash
ssh -i ~/Downloads/prod-ubntu-expense-tracker.pem ubuntu@18.139.46.170
docker exec $(docker ps -qf "name=db") env | grep POSTGRES
```

### Why the tunnel needs `127.0.0.1:5432:5432` in docker-compose

Without `ports: ["127.0.0.1:5432:5432"]` in the db service, PostgreSQL port is only
accessible inside the Docker network — not from the host's `localhost:5432`.
The SSH tunnel forwards to `localhost:5432` on the server, so the port must be exposed.

### Useful psql commands (run on server)

```bash
# Connect
docker exec -it expense-tracker-db psql -U postgres -d expense_tracker

# List tables
\dt

# Check row counts
SELECT relname, n_live_tup FROM pg_stat_user_tables ORDER BY n_live_tup DESC;

# Check migrations applied
SELECT * FROM schema_migrations;
```

### Clear all data (keep structure)

Run in DBeaver or psql:

```sql
DO $$ DECLARE r RECORD;
BEGIN
  FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
    EXECUTE 'TRUNCATE TABLE ' || quote_ident(r.tablename) || ' RESTART IDENTITY CASCADE';
  END LOOP;
END $$;
```

### Fix schema_migrations after truncate

If you truncated all tables (including `schema_migrations`), the app will try to re-run
migrations on next start and fail because the tables already exist.

Fix — mark all migrations as already applied:

```sql
INSERT INTO schema_migrations (version, dirty) VALUES
  (1, false),
  (2, false),
  (3, false);
```

### Check Docker DB logs

```bash
docker logs expense-tracker-db --tail 50
docker logs expense-tracker-api --tail 50
```

---

## 7. All Bugs & Fixes

### Bug: Samsung phone cannot connect to API

**Symptom:** "Cannot reach the server." on real device. Works fine on emulator.  
**Wrong theories tried:** HTTP vs HTTPS, DNS settings, Private DNS, static DNS, Cloudflare config, RSA cert issues.  
**Root cause:** Missing `INTERNET` permission in `AndroidManifest.xml`.  
**Fix:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

---

### Bug: "No Directionality widget found" crash

**Symptom:** App crashes on launch with `No Directionality widget found`.  
**Root cause:** `NoInternetWrapper` was placed outside `MaterialApp`, before localization delegates were registered.  
**Fix:** Move `NoInternetWrapper` inside `MaterialApp.builder`.

---

### Bug: Redis cache not working

**Symptom:** Redis connect error on API startup.  
**Root cause:** `REDIS_URL: redis:6379` missing the `redis://` scheme.  
**Fix:** `REDIS_URL: redis://redis:6379`

---

### Bug: Port conflict — frontend container vs host Nginx

**Symptom:** Frontend container fails to start; port 80 already in use.  
**Root cause:** Host Nginx owns port 80; frontend was mapped `80:80`.  
**Fix:** `"127.0.0.1:3000:80"` — bind only to localhost, use port 3000.

---

### Bug: YAML parse error in deploy.yml (line 89)

**Symptom:** GitHub Actions fails: `YAML parse error`.  
**Root cause:** Heredoc `<<NGINX` inside a YAML string — YAML treats `<<` as a merge key.  
**Fix:** Move Nginx config to `deploy/nginx.conf`. Use `sed` to replace `__DOMAIN__` at deploy time.

---

### Bug: Dashboard doesn't update after adding transaction

**Symptom:** After creating/editing/deleting a transaction, the dashboard summary cards show stale data.  
**Root cause:** Only `ref.invalidateSelf()` was called, not `_invalidateReports()`.  
**Fix:** Call `_invalidateReports()` in transaction provider after every mutation.

---

### Bug: tagTotalsProvider infinite loop

**Symptom:** App freezes / infinite rebuild loop.  
**Root cause:** Provider family key was `Map<String,String>`. Maps have no value equality in Dart — every rebuild created a new key and triggered a new provider.  
**Fix:** Changed key type to `String` in format `"from,to"`.

---

### Bug: `update()` method name conflict

**Symptom:** Compile error — `update` conflicts with `AsyncNotifierBase.update`.  
**Root cause:** Domain controllers had methods named `update()` which clashes with Riverpod internals.  
**Fix:** Renamed to `editBucket`, `editPerson`, `editTag`, `editTransaction`, `editReminder`.

---

### Bug: `S.of(context)` in const widgets

**Symptom:** Compile error when using localization strings in `const` constructors.  
**Root cause:** `S.of(context)` is a runtime call — can't be used in `const`.  
**Fix:** Remove `const` keyword from affected widgets. Use `S get l10n => S.of(context)!` getter in `State` classes.

---

### Bug: SSH tunnel port already in use

**Symptom:** `bind [127.0.0.1]:5433: Address already in use`  
**Root cause:** Previous tunnel process still running.  
**Fix:**
```bash
lsof -ti:5433 | xargs kill -9
```

---

### Bug: PostgreSQL not reachable through SSH tunnel

**Symptom:** `nc -zv 127.0.0.1 5433` fails / DBeaver connection reset.  
**Root cause:** DB Docker container had no `ports` mapping — port was only internal to Docker network.  
**Fix:** Add to `docker-compose.prod.yml`:
```yaml
db:
  ports:
    - "127.0.0.1:5432:5432"
```
Then restart: `docker compose -f docker-compose.prod.yml up -d db`

---

## 8. Localization (Bangla / English)

**Default language:** Bengali (`bn`)

### Files

| File | Purpose |
|---|---|
| `lib/l10n/app_bn.arb` | Bengali strings |
| `lib/l10n/app_en.arb` | English strings |
| `l10n.yaml` | Config: template = `app_bn.arb`, output class = `S` |
| `lib/l10n/app_localizations.dart` | Auto-generated — do not edit |

### Adding a new string

1. Add to `app_bn.arb`:
```json
"myNewKey": "আমার নতুন স্ট্রিং"
```

2. Add to `app_en.arb`:
```json
"myNewKey": "My new string"
```

3. Run:
```bash
flutter gen-l10n
```

4. Use in widget:
```dart
S.of(context)!.myNewKey
// or inside State class:
l10n.myNewKey
```

### Changing language at runtime

```dart
ref.read(localeProvider.notifier).state = const Locale('en');
await saveLocale(const Locale('en'));
```

---

## 9. Cheatsheet — Daily Dev Commands

### Local development

```bash
# Start all services
docker compose up -d

# Run Go API
go run ./cmd/...

# Run Flutter app (debug)
cd mobile_app && flutter run

# Build release APK
cd mobile_app && flutter build apk --release

# Generate localization
cd mobile_app && flutter gen-l10n

# Generate sqlc code
sqlc generate

# Create new migration
migrate create -ext sql -dir internal/db/migrations -seq <name>
```

### Production

```bash
# SSH to server
ssh -i ~/Downloads/prod-ubntu-expense-tracker.pem ubuntu@18.139.46.170

# View logs
docker logs expense-tracker-api --tail 100 -f
docker logs expense-tracker-db --tail 50

# Restart all services
cd ~/expense-tracker && docker compose -f docker-compose.prod.yml restart

# Rebuild and restart
cd ~/expense-tracker && docker compose -f docker-compose.prod.yml up -d --build

# Check all container status
docker ps

# Open DB tunnel (run on Mac)
lsof -ti:5433 | xargs kill -9
ssh -i ~/Downloads/prod-ubntu-expense-tracker.pem -L 5433:localhost:5432 -fN ubuntu@18.139.46.170
```

### Database

```bash
# Connect to prod DB via tunnel (after opening tunnel above)
psql -h 127.0.0.1 -p 5433 -U postgres -d expense_tracker

# Connect directly on server
docker exec -it expense-tracker-db psql -U postgres -d expense_tracker

# Run a SQL file
docker exec -i expense-tracker-db psql -U postgres -d expense_tracker < myfile.sql

# Backup prod database
docker exec expense-tracker-db pg_dump -U postgres expense_tracker > backup_$(date +%Y%m%d).sql

# Restore backup
docker exec -i expense-tracker-db psql -U postgres expense_tracker < backup_20260515.sql
```

---

*Last updated: 2026-05-15*
