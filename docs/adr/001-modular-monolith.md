# ADR 001: Rails Modular Monolith for Bookkeeper Agent MVP

## Status

Accepted

## Context

The product is a receipt-first bookkeeping workflow with tight coupling between:

- ingestion and file attachment
- AI extraction
- normalization and reconciliation
- duplicate detection
- human review
- internal accounting entry creation
- audit logging

The MVP also needs to ship quickly without unnecessary infrastructure.

## Decision

Use a Rails modular monolith as the backend system of record, with:

- GraphQL-Ruby as the primary business API
- PostgreSQL as the database
- Active Storage for private receipt files
- Active Job with Solid Queue for background processing
- Next.js as the separate frontend application

## Consequences

### Positive

- business logic stays in one codebase with one transactional boundary
- auditability is much easier than across multiple services
- background workers can run as a separate process without introducing another application boundary
- the design preserves room for future export adapters and eventual service extraction if the product outgrows the monolith

### Negative

- a single Rails codebase must remain disciplined about service boundaries
- queue throughput is limited by the Postgres-backed job strategy until Sidekiq/Redis is introduced later

## Deferred Decisions

- Sidekiq/Redis remains deferred until queue volume or latency justifies it
- external ledger adapters remain optional and should be implemented against the internal accounting entry model only

