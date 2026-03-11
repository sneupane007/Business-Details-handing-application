# Implementation Plan: The "Quant-Diligence" Suite

> **A self-hosted portfolio intelligence platform for investors**
> Solo dev | Flutter mobile | Self-hosted Supabase + FastAPI | Target: NEPSE + startup valuations

---

## Phase 1: Foundation & Infrastructure (Weeks 1–2)

Get the plumbing working before you write a single line of valuation logic.

### 1.1 Server Provisioning
- Spin up a single VPS (Hetzner or DigitalOcean) — 4GB RAM, 2 vCPU minimum.
- Harden immediately: SSH key-only access, disable root login, enable UFW firewall (allow 80, 443, 22 only), enable `unattended-upgrades`.
- Install Docker + Docker Compose.

### 1.2 Docker Compose Stack
Bring up the full environment with a single `docker-compose.yml`:

| Service | Role | Notes |
|---------|------|-------|
| supabase-db | PostgreSQL 15 + extensions | pg_cron, pgvector, pg_stat_statements |
| supabase-auth | GoTrue auth server | JWT issuer for all services |
| supabase-rest | PostgREST | Direct DB access from Flutter |
| supabase-realtime | WebSocket server | Live portfolio alerts |
| supabase-storage | File storage | Term sheets, PDFs, CSVs |
| fastapi-app | Custom API | Valuation logic, ingestion, integrations |
| redis | Cache + broker | Celery broker + query cache |
| celery-worker | Background processor | Valuations, data ingestion, reports |
| celery-beat | Scheduler | Daily aggregations, NEPSE sync |
| caddy | Reverse proxy | Auto-HTTPS, routing, rate limiting |

**Critical:** Pin every Docker image to a specific version tag. Never use `:latest` in production — a broken upstream update during a demo is catastrophic.

### 1.3 Networking & DNS
- `api.quantdiligence.com` → FastAPI
- `supabase.quantdiligence.com` → Supabase services (auth, rest, realtime, storage)
- Caddy handles TLS via Let's Encrypt automatically.
- All inter-service traffic stays on the internal Docker network — only Caddy is exposed to the internet.

### 1.4 Flutter Connection
- Add `supabase_flutter` to your app.
- Verify: auth handshake, a basic table read, and a file upload all succeed end-to-end.
- Set up environment configs in Flutter so you can toggle between local dev and production Supabase URLs without code changes.

### 1.5 Phase 1 Exit Criteria
- [ ] VPS hardened and Docker stack running
- [ ] Caddy serving HTTPS on both subdomains
- [ ] Flutter app authenticates and reads from Supabase
- [ ] `docker-compose down && docker-compose up -d` recovers cleanly

---

## Phase 2: Core Investor Features (Weeks 3–5)

Lock down data access first. VCs will drop you instantly if another firm can see their portfolio.

### 2.1 Authentication
- Enable Supabase Auth providers: email/password + Google OAuth + Apple Sign-In (required for iOS App Store).
- Implement full auth flow in Flutter: signup → email verification → login → token refresh → password reset.
- Create a `profiles` table linked to `auth.users`:

| Column | Type | Purpose |
|--------|------|---------|
| id | uuid (FK → auth.users) | Primary key |
| display_name | text | Investor name |
| firm_name | text | Fund or firm affiliation |
| role | enum (investor, analyst, admin) | Access tier |
| avatar_url | text | Profile image |
| onboarded_at | timestamptz | Track activation |

### 2.2 Data Isolation (RLS — Non-Negotiable)
Every table gets RLS enabled on creation. No exceptions.

**Core tables to create:**

| Table | Purpose | RLS Policy |
|-------|---------|-----------|
| portfolios | Investment portfolios per user | `auth.uid() = user_id` |
| holdings | Individual positions within a portfolio | Via portfolio ownership join |
| valuations | Computed valuation snapshots | Via portfolio ownership join |
| documents | Uploaded file metadata | `auth.uid() = user_id` |
| jobs | Background task tracking | `auth.uid() = user_id` |
| alerts | User-configured notifications | `auth.uid() = user_id` |

**Multi-level RLS pattern for team access (future-proof):**
Instead of only `auth.uid() = user_id`, build the policy around a `portfolio_members` join table from the start. This lets you add firm-level sharing later without rewriting every policy.

```
Policy: SELECT on holdings
→ EXISTS (SELECT 1 FROM portfolio_members
   WHERE portfolio_id = holdings.portfolio_id
   AND user_id = auth.uid())
```

This costs nothing now and saves weeks later if investors want to share portfolios with analysts.

### 2.3 Real-Time Portfolio Alerts
Enable Supabase Realtime on: `valuations`, `alerts`, `jobs`.

**Use cases (not generic chat — purpose-built for investors):**
- A new valuation completes → push result to the investor's phone instantly.
- A holding crosses a threshold (e.g., NEPSE stock drops 5%) → trigger an alert row → Realtime delivers it.
- A background job finishes processing → status update streams to the app.

In Flutter: `supabase.channel('portfolio-{id}').onPostgresChanges()` — one subscription per active portfolio.

**Scaling:** At >5K concurrent WebSocket connections, add a Redis Pub/Sub layer between Supabase Realtime and the FastAPI WebSocket endpoints to distribute load.

### 2.4 Document Storage
Set up Supabase Storage buckets:

| Bucket | Access | Contents |
|--------|--------|----------|
| avatars | Public | Investor profile images |
| term-sheets | Private (RLS) | Term sheets, investment agreements |
| financials | Private (RLS) | Financial statements, cap tables |
| exports | Private (RLS) | Generated reports, PDFs |

**Path convention:** `{bucket}/{user_id}/{portfolio_id}/{filename}`

This makes RLS policies trivial and keeps everything organized per deal.

**File validation:** Enforce server-side — accept only PDF, XLSX, CSV, PNG, JPG. Reject everything else. Max 50MB per file.

**Large files:** Use resumable uploads via the tus protocol (native in Supabase Storage) for anything over 10MB — prevents failed uploads on mobile connections.

**Image processing:** Avatar uploads trigger a Celery task that uses Pillow to resize to standard dimensions and store the thumbnail back to the `avatars` bucket. Never block the upload response on image processing.

### 2.5 Phase 2 Exit Criteria
- [ ] Full auth flow working in Flutter (signup through password reset)
- [ ] RLS enforced on every table — tested by attempting cross-user access
- [ ] Realtime alerts deliver to Flutter within 2 seconds
- [ ] Document upload/download working with proper access control

---

## Phase 3: Heavy Data Processing (Weeks 6–8)

The engine room. You cannot run NEPSE data ingestion or complex valuations on the main API thread.

### 3.1 The Queue Architecture
Any operation taking more than 2 seconds → background job. No exceptions.

**Celery task modules:**

| Module | Tasks |
|--------|-------|
| tasks/ingestion.py | CSV parsing, data cleaning, NEPSE feed sync |
| tasks/valuation.py | DCF models, comparable analysis, metric computation |
| tasks/reports.py | PDF report generation, portfolio summaries |
| tasks/alerts.py | Threshold checks, notification triggers |
| tasks/notifications.py | FCM push notifications for mobile devices |
| tasks/maintenance.py | Stale data cleanup, index rebuilds |

### 3.2 The Ingestion Pipeline (End-to-End)

**Step 1 — Upload:** Investor uploads a CSV of startup metrics from Flutter.

**Step 2 — Validate:** FastAPI endpoint receives the file, runs schema validation (expected columns, data types, row limits). Rejects bad data immediately with clear error messages — don't waste queue time on garbage input.

**Step 3 — Enqueue:** FastAPI creates a `jobs` row (status: `pending`, type: `ingestion`, params: file reference) and enqueues the Celery task. Returns the `job_id` to Flutter immediately.

**Step 4 — Process:** Celery worker picks up the task:
- Updates status → `processing`
- Parses and cleans the CSV (handle NaN, duplicates, currency normalization)
- Maps data to the correct portfolio/holdings
- Flags anomalies (e.g., revenue that jumped 10,000% — likely a data entry error)
- Stores cleaned data in the database

**Step 5 — Compute:** If valuation is requested, chain a second Celery task that runs the calculations on the cleaned data.

**Step 6 — Deliver:** Update job status → `completed` with result summary. Flutter receives the update via Realtime subscription on the `jobs` table, or the user can poll `GET /api/jobs/{job_id}` if Realtime is unavailable.

**Error handling:** If any step fails, update status → `failed` with a human-readable error message. The investor sees "Your CSV had 3 rows with missing revenue data" — not a stack trace.

### 3.3 NEPSE Data Sync
- Set up a Celery Beat schedule to pull NEPSE market data at regular intervals (e.g., every 15 minutes during market hours, daily close-of-day snapshot).
- Store in a `market_data` table: symbol, open, high, low, close, volume, date.
- Index on `(symbol, date DESC)` for fast lookups.
- This data is shared (not user-specific) — no RLS needed, but make it read-only for non-admin roles.

### 3.4 Push Notifications (FCM)
- Integrate Firebase Cloud Messaging for mobile push delivery.
- When an alert threshold is crossed or a job completes, the `tasks/notifications.py` Celery task sends an FCM message to the investor's device token.
- Store device tokens in the `profiles` table (or a `device_tokens` child table if multi-device support is needed).
- Use FCM data messages (not notification messages) so Flutter handles the display — this allows deep linking directly into the relevant portfolio.

### 3.5 Analytics & Precomputation
- **pg_cron** (built into Supabase Postgres): schedule daily aggregation queries during off-peak hours.
- Precompute into summary tables: `portfolio_daily_summary`, `holding_performance`.
- Dashboard endpoints read from these tables — never run heavy joins in real-time.
- For investor-facing metrics (IRR, MOIC, TVPI): compute on write (when new data arrives), not on read.

### 3.6 Phase 3 Exit Criteria
- [ ] CSV upload → processing → result delivery works end-to-end
- [ ] Job failures produce clear, user-facing error messages
- [ ] NEPSE data syncing on schedule
- [ ] Dashboard loads in under 500ms (precomputed data)
- [ ] Celery worker recovers gracefully after restart (no lost jobs)
- [ ] FCM push notifications delivered on job completion and threshold alerts

---

## Phase 4: Launch Prep & Security (Week 9)

A slick UI means nothing if the server crashes during a demo.

### 4.1 Automated Backups
- `pg_dump` on cron → compressed → pushed to Backblaze B2 ($0.005/GB).
- Schedule: every 6 hours for the database, daily for file storage.
- **Test the restore process.** A backup you've never restored is not a backup.
- Keep 7 daily + 4 weekly snapshots. Auto-delete older ones.

### 4.2 Security Lockdown

**Authentication layer:**
- Validate JWTs on every FastAPI endpoint using the shared Supabase JWT secret.
- Create a reusable FastAPI dependency — never validate inline in route handlers.
- Implement token refresh logic so sessions don't silently expire during use.

**Database layer:**
- Audit every table: RLS must be ON. Run a query to verify: `SELECT tablename FROM pg_tables WHERE rowsecurity = false AND schemaname = 'public'` — this must return zero rows.
- All queries via parameterized statements (SQLAlchemy). No string concatenation. Ever.

**Network layer:**
- CORS locked to your app's domain only. No wildcards.
- Caddy rate limiting: 100 req/min per IP on auth endpoints, 300 req/min on API endpoints.
- FastAPI middleware: per-user rate limiting using Redis (token bucket algorithm).
- All secrets in environment variables — `.env` file in `.gitignore`, never committed.

**Operational:**
- Docker containers run as non-root users.
- PostgreSQL SSL enabled for all connections.
- Dependency audit: `pip audit` + `npm audit` before launch, then monthly.

### 4.3 Monitoring & Observability
- **Uptime Kuma** (self-hosted): health checks on every service, alerts via Telegram or email.
- **Structured logging:** JSON logs from FastAPI with request ID, user ID, duration. Ship to a file, rotate with logrotate.
- **Sentry** (free tier): error tracking for both FastAPI and Flutter. Catch crashes before your users report them.
- **pg_stat_statements:** enabled in Postgres to identify slow queries. Review weekly.

### 4.4 Load Testing
Before you demo to anyone, simulate realistic traffic:
- Use `locust` (Python) to simulate 100 concurrent users hitting auth, CRUD, and file upload endpoints.
- Verify WebSocket connections hold stable under load.
- Identify the first bottleneck — fix it before launch.

### 4.5 Phase 4 Exit Criteria
- [ ] Backup restore tested successfully on a fresh server
- [ ] Zero tables with RLS disabled
- [ ] Rate limiting verified (test with `ab` or `hey`)
- [ ] Monitoring alerts fire correctly (kill a service, confirm alert arrives)
- [ ] Load test passes: 100 concurrent users, p95 response < 1s
- [ ] Deployment runbook written — you should be able to rebuild from zero in under 1 hour

---

## Key Decisions Log

| Decision | Rationale |
|----------|-----------|
| Self-hosted Supabase over Firebase | Full control, no vendor lock-in, real Postgres for complex valuations |
| FastAPI over Django/Express | Async, fast, auto-docs, Python ecosystem for financial computation |
| portfolio_members join table from day one | Enables firm-level sharing without rewriting RLS later |
| Precomputed analytics over real-time queries | Dashboard speed matters more than data freshness for daily metrics |
| Celery over simple background threads | Reliable retries, dead letter handling, scales by adding workers |
| Caddy over Nginx | Auto-HTTPS with zero config, simpler for solo dev |