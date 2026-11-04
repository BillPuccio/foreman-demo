#!/usr/bin/env bash
# Demo guardrail check (BCW-11).
#
# Fails if the repo contains real Blue Collar Workflows domains, anything that
# looks like a credential, or a committed .env file. See docs/demo-guardrails.md.
#
# Usage:
#   scripts/check-demo-guardrails.sh           # scan all tracked files
#   scripts/check-demo-guardrails.sh --staged  # scan staged changes (pre-commit hook)

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

mode="${1:-all}"

# Files that legitimately contain these patterns.
exclude_re='^(scripts/check-demo-guardrails\.sh|\.gitleaks\.toml)$'

# name|extended regex
checks=(
  "Real Blue Collar Workflows domain|[A-Za-z0-9.-]*bluecollarworkflows\.(com|net|io|app|dev|co)"
  "Anthropic API key|sk-ant-[A-Za-z0-9_-]{20,}"
  "OpenAI-style API key|sk-(proj-)?[A-Za-z0-9]{32,}"
  "AWS access key ID|AKIA[0-9A-Z]{16}"
  "GitHub token|(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{40,}"
  "Slack token|xox[abprs]-[A-Za-z0-9-]{10,}"
  "Google API key|AIza[0-9A-Za-z_-]{35}"
  "Stripe live key|(sk|rk)_live_[A-Za-z0-9]{20,}"
  "Private key block|-----BEGIN ([A-Z]+ )?PRIVATE KEY-----"
)

if [[ "$mode" == "--staged" ]]; then
  files=$(git diff --cached --name-only --diff-filter=ACMR)
else
  files=$(git ls-files)
fi

files=$(printf '%s\n' "$files" | grep -Ev "$exclude_re" || true)

failed=0

# Committed .env files (only .env.example is allowed).
env_files=$(printf '%s\n' "$files" | grep -E '(^|/)\.env(\..+)?$' | grep -Ev '(^|/)\.env\.example$' || true)
if [[ -n "$env_files" ]]; then
  echo "✗ .env files must not be committed (only .env.example):"
  printf '    %s\n' $env_files
  failed=1
fi

[[ -z "$files" ]] && { [[ $failed -eq 0 ]] && echo "✓ Demo guardrails: nothing to scan."; exit $failed; }

for check in "${checks[@]}"; do
  name="${check%%|*}"
  pattern="${check#*|}"
  if [[ "$mode" == "--staged" ]]; then
    # Scan only added lines in the staged diff.
    hits=$(git diff --cached -U0 -- $files | grep -E '^\+[^+]' | grep -En -e "$pattern" || true)
  else
    hits=$(printf '%s\n' "$files" | tr '\n' '\0' | xargs -0 grep -InE -e "$pattern" -- 2>/dev/null || true)
  fi
  if [[ -n "$hits" ]]; then
    echo "✗ $name:"
    printf '%s\n' "$hits" | sed 's/^/    /'
    failed=1
  fi
done

# Use gitleaks too, if it's installed.
if command -v gitleaks >/dev/null 2>&1; then
  if [[ "$mode" == "--staged" ]]; then
    gitleaks protect --staged --config .gitleaks.toml --redact --no-banner || failed=1
  else
    gitleaks detect --config .gitleaks.toml --redact --no-banner || failed=1
  fi
fi

if [[ $failed -ne 0 ]]; then
  echo
  echo "Demo guardrail check failed. Remove the values above (see docs/demo-guardrails.md)."
  exit 1
fi

echo "✓ Demo guardrails: no real credentials, BCW domains or .env files found."
