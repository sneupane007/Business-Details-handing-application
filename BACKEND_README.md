# Backend Architecture — Flutter Mobile App

> **Solo dev | Bootstrap budget | Self-hosted | 1K → 50K+ users**

---

## Stack

| Layer | Tech | Role |
|-------|------|------|
| API | FastAPI (Python 3.11+) | Custom logic, processing, REST endpoints |
| Database | PostgreSQL 15 (Supabase) | Primary store + Row Level Security |
| Auth | Supabase Auth (GoTrue) | JWT auth: email, OAuth, magic links |
| Realtime | Supabase Realtime | WebSocket live updates via Postgres changes |
| Storage | Supabase Storage | S3-compatible file uploads |
| Queue | Celery + Redis | Background jobs, analytics, scheduled tasks |
| Cache | Redis | Session cache, rate limiting, hot data |
| Proxy | Caddy | Auto-HTTPS, routing |
| Deploy | Docker Compose | All services in one stack |

---

## Infrastructure

| Phase | Users | Server | Cost/mo |
|-------|-------|--------|---------|
| Launch | 0–1K | 4GB RAM, 2 vCPU, 80GB SSD | $6–12 |
| Growth | 1K–10K | 8GB RAM, 4 vCPU, 160GB SSD | $20–40 |
| Scale | 10K–50K+ | Multi-server + managed DB + CDN | $80–200+ |

**Providers:** Hetzner (best value), DigitalOcean, Vultr

**Domains:**
- `api.yourdomain.com` → FastAPI
- `supabase.yourdomain.com` → Supabase services

---

## Feature Map

### Auth & Roles
- Supabase Auth handles login flows; `supabase_flutter` SDK in app
- Providers: email/password, Google OAuth, Apple Sign-In
- `profiles` table (FK → auth.users): display_name, avatar_url, role enum
- RLS on every table — `auth.uid() = user_id` pattern
- FastAPI validates Supabase JWTs via shared secret for protected endpoints

### Realtime
- Enable Realtime on: `messages`, `notifications`, `activity_feed`
- Flutter subscribes via `supabase.channel().onPostgresChanges()`
- Chat: messages table (sender_id, room_id, content, created_at)
- Presence: Supabase Realtime presence tracks online users per channel
- Complex logic (typing, read receipts): FastAPI WebSocket endpoints
- Scale trigger: >5K concurrent WS → add Redis Pub/Sub layer

### File Uploads
- Buckets: `avatars` (public), `documents` (private), `media` (private)
- Path structure: `bucket/user_id/category/filename`
- Flutter: `supabase.storage.from('bucket').upload()`
- Image processing: Celery task on upload → Pillow resize → store back
- Large files: resumable uploads via tus protocol (native in Supabase Storage)
- Validate file size + type both client-side and server-side

### Data Processing & Analytics
- Long tasks → Celery background jobs, never block the API
- Pattern: POST /api/jobs → enqueue → return job_id → poll or Realtime
- `jobs` table: type, status (pending/processing/completed), params, result
- Analytics: Celery beat daily aggregation → `analytics_daily` table
- pg_cron for DB maintenance: token cleanup, archival, materialized views

---

## Core Tables

| Table | Key Columns | Notes |
|-------|-------------|-------|
| profiles | id (FK auth.users), display_name, role, avatar_url | RLS per user |
| messages | id, room_id, sender_id, content, type, created_at | Realtime; idx on (room_id, created_at) |
| rooms | id, name, type (dm/group) | Join via room_members |
| notifications | id, user_id, type, payload, read, created_at | Realtime on INSERT |
| files | id, user_id, bucket, path, size, mime_type | Metadata only; blobs in Storage |
| jobs | id, user_id, type, status, params, result | Realtime for status updates |
| analytics_daily | id, metric, value, dimension, date | Precomputed aggregations |

**Indexing rules:**
- All FKs indexed (used in every RLS check)
- Composite: `(room_id, created_at DESC)` for message pagination
- Partial: `WHERE status != 'completed'` on jobs

---

## Project Structure

```
backend/
├── docker-compose.yml
├── caddy/Caddyfile
├── supabase/                # Supabase Docker config + .env
├── fastapi/app/
│   ├── main.py              # Entrypoint, middleware, routers
│   ├── auth/                # JWT validation, user deps
│   ├── routers/             # API routes (users, jobs, etc.)
│   ├── services/            # Business logic
│   ├── models/              # SQLAlchemy + Pydantic models
│   └── tasks/               # Celery task definitions
├── migrations/              # Alembic DB migrations
├── tests/                   # pytest suite
└── scripts/                 # Deploy + maintenance
```

---

## Timeline (9 weeks)

| Wk | Phase | Deliverables |
|----|-------|-------------|
| 1–2 | Foundation | VPS + Docker, Supabase running, FastAPI scaffold, schema + RLS, Caddy HTTPS, Flutter connected |
| 3–5 | Core | Auth flows, profiles, file uploads + thumbnails, Realtime subscriptions, chat system |
| 6–8 | Processing | Celery pipeline, analytics, push notifications (FCM), Sentry logging, test suite |
| 9 | Launch | Backups (pg_dump → B2), monitoring (Uptime Kuma), rate limiting, security audit, docs |

---

## Scaling Triggers

| Signal | Action |
|--------|--------|
| DB CPU >70% | Migrate Postgres to managed service |
| API >500ms | Add Redis caching, optimize indexes |
| >5K WS connections | Scale Realtime or add Redis Pub/Sub |
| Storage >100GB | Move to S3/Cloudflare R2 (free egress) |
| Queue backlog growing | Add Celery worker containers |
| >20K users | Split: DB on server 1, API on server 2 |
| >50K users | AWS migration: ECS + RDS + ElastiCache + S3 |

---

## Security Checklist

- [ ] RLS on every table — no exceptions
- [ ] JWT validation on every FastAPI endpoint
- [ ] Parameterized queries only (SQLAlchemy)
- [ ] CORS locked to app domain — no wildcards
- [ ] Secrets in env vars — never in git
- [ ] Postgres SSL between services
- [ ] Docker containers run as non-root
- [ ] Auto security updates (unattended-upgrades)
- [ ] Rate limiting on auth endpoints
- [ ] Monthly `pip audit` + `npm audit`

---

## AWS Migration Path (when needed)

| Current | AWS Equivalent |
|---------|---------------|
| Supabase Postgres | RDS / Aurora PostgreSQL |
| FastAPI container | ECS / EKS / Lambda + Mangum |
| Supabase Storage | S3 |
| Redis | ElastiCache |
| Celery workers | ECS tasks |
| Caddy | ALB + ACM |

Everything is containerized + standard protocols — migration is a lift-and-shift.
