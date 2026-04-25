# Bookkeeper Agent

Standalone receipt-first bookkeeping product scaffolded as a monorepo with:

- `apps/api`: Ruby on Rails modular monolith for auth, GraphQL, receipt processing, auditability, and posting
- `apps/web`: Next.js + React + TypeScript frontend with shadcn/ui-style components for upload and review workflows

## Current State

This repository contains production-oriented scaffolding for the MVP described in the implementation plan:

- multi-tenant organizations and memberships
- Active Storage-based receipt ingestion
- receipt extraction pipeline interfaces for Gemini
- normalization, reconciliation, category, duplicate, confidence, review, and posting services
- GraphQL schema, types, and mutations for the main workflow
- Next.js review dashboard scaffold

## Repo Layout

```text
apps/
  api/   Rails API, GraphQL, jobs, domain services, migrations
  web/   Next.js app with review dashboard and receipt workflows
docs/
  adr/   Architecture decision records
  prompts/
```

## Local Setup

### Backend

Install Ruby 3.3 and Bundler, then:

```bash
cd apps/api
bundle install
bin/setup
bin/rails db:prepare
bin/rails server
```

Environment variables expected by the API:

- `DATABASE_URL`
- `SECRET_KEY_BASE`
- `GEMINI_API_KEY`
- `ACTIVE_STORAGE_SERVICE`

## Railway Notes

For the Rails API service on Railway:

- attach a PostgreSQL service and expose its connection string to the API as `DATABASE_URL`
- set `SECRET_KEY_BASE` on the API service
- if you deploy from the repo root, use the repo-root `Dockerfile`; if you deploy `apps/api` as its own Railway service, use `apps/api/Dockerfile`

If `DATABASE_URL` is missing, Rails will now fail fast in production instead of falling back to `localhost:5432`.

### Frontend

```bash
cd apps/web
npm install
npm run dev
```

Environment variables expected by the web app:

- `API_URL`
- `NEXT_PUBLIC_API_URL`

## Notes

- Redis is intentionally deferred. The backend is configured for PostgreSQL-backed jobs via Solid Queue.
- The Rails and Next.js code is intentionally modular so the worker can run as a separate process from the web server without splitting into separate services.
- Receipt posting remains internal-platform-neutral; export adapters can be added later without polluting the core bookkeeping model.
