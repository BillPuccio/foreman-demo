# Contributing

Thanks for taking a look. Foreman Demo is a personal portfolio project with one developer, so I'm not looking for pull requests right now. That said, you're welcome to:

- **Open an issue** if you spot a bug, a security concern, or something in the docs that's unclear.
- **Fork it** and use it however you like under the [MIT License](LICENSE).

If you do send a pull request, I'll read it, but I may not merge it.

## Ground rules

This is a demonstration project. Anything added to it has to follow the [demo guardrails](docs/demo-guardrails.md):

1. No real Blue Collar Workflows endpoints, keys, credentials or customer data.
2. Configuration comes from environment variables. Only `.env.example`, with placeholder values, is committed.
3. Seed and test data is fictional.

If you find something real in the repo, please open an issue (without pasting the secret itself) so it can be revoked and removed.

## How work is done here

These are the conventions I follow. They're written down so the history makes sense to anyone reading it.

**Tracking.** Work is planned in Jira, and each change maps to a ticket key such as `BCW-12`.

**Branches.** One branch per ticket, named for the ticket type:

| Ticket type | Branch prefix | Example |
| --- | --- | --- |
| Story | `story/` | `story/bcw-12` |
| Task | `task/` | `task/bcw-24` |
| Bug | `bugfix/` | `bugfix/bcw-60` |
| Feature | `feature/` | `feature/quote-pdf-export` |

**Commits.** The first commit on a branch starts with the ticket key, for example `BCW-12: Add license and contributing guide`.

**Pull requests.** Every branch is merged into `main` through a pull request.

**Guardrail check.** Turn on the pre-commit hook once per clone, so every commit is checked for secrets and real BCW domains:

```sh
git config core.hooksPath .githooks
```

**Decisions.** Significant technical decisions are recorded as ADRs in [`docs/adr/`](docs/adr/). A change that goes against an existing ADR should come with a new ADR that supersedes it.

**Code style.** Formatting follows [`.editorconfig`](.editorconfig). Each component (`api/`, `mcp-server/`, `ios/`) has its own README with build and test instructions.
