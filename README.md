# Foreman Demo

> **Demonstration project.** This repository is a portfolio showcase. It uses fictional data, has no connection to any Blue Collar Workflows production system, and should not be used with real customer information. See [demo guardrails](docs/demo-guardrails.md) for the rules and checks that keep it that way.

Foreman is an AI assistant for small blue-collar service businesses. A job request comes in, Foreman drafts a quote using the business's price book, and the owner reviews and approves it before anything goes out. Foreman can draft; only a person can approve.

This repo shows the full path end to end:

- **iOS app (SwiftUI):** job intake, a chat with Foreman, and quote review/approval
- **API (C# / ASP.NET Core):** the system of record for customers, jobs and quotes, and the orchestrator for Foreman's model calls
- **MCP server:** the tools Foreman uses to look up customers, jobs and pricing, and to draft quotes
- **Docs:** architecture, decision records and setup guides

## Architecture

```mermaid
flowchart LR
    App[iOS app<br/>SwiftUI] -->|HTTPS| API[API<br/>ASP.NET Core]
    API -->|prompts + tool results| LLM[(LLM provider)]
    API -->|MCP client| MCP[MCP server<br/>Foreman tools]
    MCP --> DB[(Demo data)]
    API --> DB
```

The approval gate lives in the API. The MCP server's write tools can only create drafts.

## Repository layout

| Folder | What's in it | Status |
| --- | --- | --- |
| [`ios/`](ios/) | SwiftUI app | Not started |
| [`api/`](api/) | ASP.NET Core API and Foreman orchestration | Not started |
| [`mcp-server/`](mcp-server/) | MCP server exposing Foreman's tools | Not started |
| [`docs/`](docs/) | Architecture notes and decision records ([`docs/adr/`](docs/adr/)) | In progress |

Each folder is a self-contained project with its own README, build and tests, so any piece can be built and run on its own.

## Getting started

Configuration comes from environment variables. Copy [`.env.example`](.env.example) to `.env` and fill in your own values. `.env` is git-ignored and must never be committed.

Turn on the pre-commit guardrail check once per clone:

```sh
git config core.hooksPath .githooks
```

Setup instructions will be added as each component lands. The goal is a single command to run the API and MCP server locally with seeded demo data, plus an Xcode project that points at it.

## Continuous integration

Each component has its own GitHub Actions workflow in [`.github/workflows/`](.github/workflows/). Automatic runs are turned off for now, since this is a single-developer project. Each workflow can still be started by hand from the Actions tab, and its push and pull request triggers are left in the file, commented out, so they're easy to turn back on.

| Workflow | Runner | What it does |
| --- | --- | --- |
| `api.yml` | Ubuntu | `dotnet restore`, build and test for `api/` |
| `mcp-server.yml` | Ubuntu | `dotnet restore`, build and test for `mcp-server/` |
| `ios.yml` | macOS | `xcodebuild test` on an iPhone simulator for `ios/` |

Until a component's project exists, its workflow passes with a notice that it skipped the build.

## Project tracking

Work is planned in epics: repo foundation, domain model, API, MCP server, Foreman assistant, iOS app, and showcase/docs.
