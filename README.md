# Bookkeeper Agent

Standalone receipt-first bookkeeping product scaffolded as a monorepo with:

- `apps/api`: Ruby on Rails modular monolith for auth, GraphQL, receipt processing, auditability, and posting
- `apps/web`: Next.js + React + TypeScript frontend with shadcn/ui-style components for upload and review workflows

## Current State

This repository contains production-oriented scaffolding for the MVP described in the implementation plan:

- multi-tenant organizations and memberships
- OAuth-backed identity linking
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
- `SESSION_SECRET`
- `GEMINI_API_KEY`
- `OIDC_CLIENT_ID`
- `OIDC_CLIENT_SECRET`
- `OIDC_ISSUER`
- `APP_HOST`
- `ACTIVE_STORAGE_SERVICE`

### Frontend

```bash
cd apps/web
npm install
npm run dev
```

Environment variables expected by the web app:

- `NEXT_PUBLIC_API_URL`

## Notes

- Redis is intentionally deferred. The backend is configured for PostgreSQL-backed jobs via Solid Queue.
- The Rails and Next.js code is intentionally modular so the worker can run as a separate process from the web server without splitting into separate services.
- Receipt posting remains internal-platform-neutral; export adapters can be added later without polluting the core bookkeeping model.

