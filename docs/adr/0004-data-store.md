# 0004. Data store

- **Status:** Accepted
- **Date:** 2026-11-04
- **Deciders:** Bill Puccio

## Context

The demo stores customers, jobs, a price book and quotes, all fictional, seeded data. The main goal is that someone can clone the repo and have it running in minutes (BCW-47), with no database server to install. The data model should still look like a real business system, because the demo is meant to be productionizable into Blue Collar Workflows later.

Both the API and the MCP server need the data. The API owns writes and the approval gate. The MCP server reads data and creates draft quotes.

## Decision

- **SQLite** as the demo database, accessed through **EF Core** with code-first migrations (BCW-14).
- The entities, `DbContext` and migrations live in one shared .NET class library (for example `Foreman.Data`). The API and the MCP server both reference it.
- **The API owns the schema.** It applies migrations and seeds demo data (BCW-15) on startup in development.
- **The approval gate is enforced in code, not only in the UI.**
  - The only way a quote becomes Approved is the API's approval endpoint, which requires a human user action (BCW-19).
  - The shared library exposes a draft-only write path for the MCP server. It can create or update quotes in **Draft** status only, and has no method that approves or sends.
- SQLite runs in WAL mode so the API and MCP server can read and write the same file safely at demo-level load. In docker compose, the database file lives on a shared volume.
- The database file is git-ignored. Developers recreate it from migrations and seed data.

## Consequences

- Zero setup: no database server, credentials or container is needed for local runs.
- Tests can use a fresh SQLite database per test (file-based or in-memory) with the same provider as production-like runs.
- SQLite allows one writer at a time. That's fine for a demo but not for real multi-user load.
- Two processes sharing one database file is a demo-friendly shortcut. A production version would more likely have the MCP server call the API, or use a server database. Either way, the draft-only rule stays the same.
- **Revisit trigger:** moving to PostgreSQL when productionizing. EF Core makes that a provider and migration change rather than a rewrite. That would be a new ADR superseding this one.

## Alternatives considered

- **PostgreSQL in docker compose:** closer to production, but adds a container and startup wait, and isn't needed for fictional demo data.
- **EF Core in-memory provider:** easy, but it doesn't enforce relational constraints and loses data on restart.
- **JSON files:** simplest of all, but no transactions, queries or migrations, and the data layer wouldn't be credible.
- **MCP server calls the API instead of the database:** cleaner ownership. It's a reasonable future change, but it adds an auth hop and coupling that this ADR avoids for now.
