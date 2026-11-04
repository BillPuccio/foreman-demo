# 0002. MCP server language and transport

- **Status:** Proposed. The BCW-24 spike confirms or revises this decision, then marks it Accepted.
- **Date:** 2026-11-04
- **Deciders:** Bill Puccio

## Context

Foreman's tools live in a separate MCP server: read-only lookups for customers, jobs and the price book, and a `draft_quote` tool that can create drafts but never approve or send them.

The server has two kinds of clients:

1. **The API**, which runs Foreman's tool-use loop in production-like runs (docker compose, BCW-47). The API and the server run as separate processes or containers.
2. **Local developer tools** such as MCP Inspector and Claude Desktop (BCW-31), which normally launch a server as a child process.

MCP defines two standard transports: **stdio** (client launches the server and talks over stdin/stdout) and **Streamable HTTP** (server runs as an HTTP service). Keeping the MCP server separate from the API is deliberate. It shows the protocol boundary clearly, and the same server can be used by any MCP client, not just Foreman.

## Decision

- **Language:** C#, using the official **Model Context Protocol C# SDK** (`ModelContextProtocol` NuGet packages, with `ModelContextProtocol.AspNetCore` for HTTP hosting).
- **Transports:** support both, chosen at startup by configuration:
  - **Streamable HTTP** when the API calls the server (the default in docker compose).
  - **stdio** for MCP Inspector and Claude Desktop.
- Tool definitions are written once and registered on whichever transport is active.
- Tool behavior is the same on both transports. In particular, there is no approve or send tool on either one.
- Over HTTP the server listens only on the internal compose network or localhost. The demo doesn't expose it publicly.

## Consequences

- Same language as the API ([ADR-0001](0001-csharp-dotnet-api.md)), so the server can share the domain and data-access project described in [ADR-0004](0004-data-store.md).
- The API uses the same SDK's client side, and its tool definitions plug into the provider abstraction in [ADR-0003](0003-llm-provider-abstraction.md).
- Supporting two transports adds a small amount of startup and config code, and tests should cover at least one end-to-end run on each.
- In stdio mode nothing may write to stdout except protocol messages, so logging must go to stderr.
- The SDK is still changing. Pin package versions and note upgrades in the changelog.

## To confirm in BCW-24

- The C# SDK's current version supports the tool, resource and Streamable HTTP features we need.
- MCP Inspector and Claude Desktop connect over stdio.
- The API can call the server over Streamable HTTP inside docker compose.
- Whether the HTTP endpoint needs a simple shared-secret header for the demo, or network isolation is enough.

## Alternatives considered

- **TypeScript MCP SDK:** the most mature SDK, but it adds a second language and runtime and prevents sharing domain code with the API.
- **Python MCP SDK:** same trade-off as TypeScript.
- **Hosting the tools inside the API process:** simpler to deploy, but hides the MCP boundary this project is meant to show, and other MCP clients couldn't reuse the tools.
- **stdio only:** the API would have to launch the server as a child process, which fits poorly with containers.
- **HTTP only:** works, but stdio is how Claude Desktop and Inspector are most easily set up for local testing.
