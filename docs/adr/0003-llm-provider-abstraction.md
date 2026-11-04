# 0003. LLM provider abstraction

- **Status:** Accepted
- **Date:** 2026-11-04
- **Deciders:** Bill Puccio

## Context

Foreman needs a large language model to read a job request, decide which tools to call, and draft a quote. Model providers, models and prices change quickly. Tests also need to run without network access, API keys or cost.

Foreman's guardrails (BCW-35) depend on the API controlling the tool-use loop directly. That means iteration caps, timeouts, logging of every tool call, and a hard refusal to approve or send anything. The model should suggest tool calls, and the API should decide whether they run.

## Decision

- The API talks to models only through **`Microsoft.Extensions.AI`'s `IChatClient`** interface. No Foreman code depends on a provider SDK directly.
- **First real provider:** Anthropic Claude, behind an `IChatClient` implementation. Use an official SDK adapter if one fits. Otherwise, write a thin adapter over the HTTP API. BCW-33 confirms which.
- **Test provider:** a scripted fake `IChatClient` that returns predetermined responses and tool calls, so the loop and guardrails can be tested deterministically.
- **The API owns the tool loop** (BCW-34). We do not turn on automatic function invocation. Each turn, the API:
  1. sends the conversation and the MCP tool list to the model,
  2. checks each requested tool call against an allow-list and the iteration and token caps,
  3. runs allowed calls through the MCP client and logs them,
  4. returns results to the model, and stops at the cap or when the model gives a final answer.
- Provider, model name and limits are configuration. The API key comes from an environment variable (for example `FOREMAN_LLM_API_KEY`) and is never committed.
- Prompts (BCW-32) are kept in versioned files, not in the provider adapter.

## Consequences

- Switching providers, or adding a local model, means writing or adding an `IChatClient` registration. The loop, prompts and guardrails stay the same.
- MCP tools from the C# SDK map naturally onto `Microsoft.Extensions.AI` tool types, which keeps glue code small.
- Owning the loop is more code than built-in auto-invocation, but it makes every guardrail explicit and testable.
- Provider-specific features (prompt caching, extended thinking, etc.) are only available through the adapter's options. We'll use them sparingly so the abstraction stays honest.
- The quote eval set (BCW-36) runs against the real provider and is kept out of the default CI run so CI doesn't need a key or incur cost.

## Alternatives considered

- **Call one provider's SDK directly:** the fastest start, but it ties the loop and tests to one vendor and makes faking harder.
- **A custom `IForemanModel` interface:** full control, but it duplicates what `Microsoft.Extensions.AI` already provides and is less familiar to .NET readers.
- **Semantic Kernel or another agent framework:** more features than the demo needs, and it hides the tool loop the project is meant to show.
