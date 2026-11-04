# Demo guardrails

foreman-demo is a public portfolio project. It must never contain or connect to anything real from Blue Collar Workflows. This page lists the rules and the checks that enforce them.

## Rules

1. **No real BCW endpoints.** No production or staging URLs, domains, webhooks or service names from Blue Collar Workflows. Code talks only to `localhost`, the docker compose network, or a model provider using your own personal key.
2. **No real keys or credentials.** No API keys, tokens, passwords, certificates or signing secrets in the repo, in any branch or commit.
3. **No real data.** Customers, jobs, price books and quotes are fictional seed data (BCW-15). Don't paste real customer names, addresses, phone numbers or prices, even in tests or screenshots.
4. **Config comes from environment variables.** The only committed config file with secret-shaped values is [`.env.example`](../.env.example), and it holds placeholders only. Your real values go in `.env`, which is git-ignored. For .NET, user secrets (`dotnet user-secrets`) are also fine.
5. **The demo says it's a demo.** The README carries the disclaimer, and the app shows one too (see below).

Using the Blue Collar Workflows name and branding is fine. Using its systems is not.

## Checks

| Check | Where | What it catches |
| --- | --- | --- |
| `scripts/check-demo-guardrails.sh` | Run by hand, or by the pre-commit hook | Real BCW domains, common API key and token formats, private key blocks, committed `.env` files |
| Pre-commit hook (`.githooks/pre-commit`) | Your machine, on every commit | Same checks, on staged changes only |
| gitleaks (optional) | Run by the same script if it's installed | gitleaks' built-in rules plus the BCW domain rule in [`.gitleaks.toml`](../.gitleaks.toml) |
| GitHub secret scanning and push protection | GitHub | Known provider secrets in pushes and in history |

### Turn on the pre-commit hook (once per clone)

```sh
git config core.hooksPath .githooks
```

To scan the whole repo at any time:

```sh
scripts/check-demo-guardrails.sh
```

For deeper scanning, install gitleaks (`brew install gitleaks`). The script uses it automatically when it's available.

### Turn on GitHub secret scanning

Secret scanning and push protection are free for public repositories. In the repo on GitHub, go to **Settings → Advanced Security** (called **Code security** on some accounts) and enable:

- **Secret Protection** (secret scanning)
- **Push protection**, which blocks pushes that contain a detected secret

## If something real gets committed

1. **Revoke or rotate the secret first.** Once a secret has been pushed to a public repo, assume it's compromised, even if you delete it right away.
2. Remove it from the code and commit the fix.
3. If it reached GitHub, rewrite history to remove it (for example with `git filter-repo`) and force-push. Removing it in a new commit isn't enough, because it's still in the history.

## In-app disclaimer (for the iOS app)

When the app is built (BCW-6), it should make it obvious that it's a demo:

- A persistent "DEMO" marker visible on the main screens (for example in the navigation bar or as a small banner).
- A one-time notice on first launch: "Foreman Demo uses fictional data and isn't connected to any real business system. Don't enter real customer information."
- The same text on an About or Settings screen, so the disclaimer can be found again later.
