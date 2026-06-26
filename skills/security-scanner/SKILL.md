---
name: security-scanner
description: Use before any production deploy or when asked to audit security. Scans for hardcoded secrets, .env exposure, git history leaks, dependency vulnerabilities, and OWASP issues. Trigger on "security scan", "check for secrets", "audit security".
---

# Security Scanner

Run when: user says "security scan", "check for secrets", "audit security", or before any deploy.

## Scripts

This skill ships three executable scripts. Each takes an optional `[project-dir]`
argument and defaults to the current directory, so they run standalone from any
checkout.

| Script | Purpose |
|--------|---------|
| `scripts/scan-secrets.sh [dir]` | Hardcoded secrets, tracked .env, credential JSONs, git history leaks |
| `scripts/scan-deps.sh [dir]` | npm audit + pip-audit for dependency vulnerabilities |
| `scripts/scan-owasp.sh [dir]` | SQL injection patterns, CORS wildcards, eval/exec, route auth |

**Workflow:** Run all three for a full scan. From the skill folder, pointing at
the project you want to audit:

```bash
bash scripts/scan-secrets.sh ./path/to/project
bash scripts/scan-deps.sh ./path/to/project
bash scripts/scan-owasp.sh ./path/to/project
```

(Or omit the argument to scan the current directory.)

## Scan checklist

### 1. Secrets in code
```bash
# Search for hardcoded keys, tokens, passwords
grep -rn --include="*.{ts,tsx,js,jsx,py,json,yaml,yml,toml,sh}" \
  -E "(api[_-]?key|secret|password|token|credential|private[_-]?key)\s*[:=]\s*['\"][^'\"]{8,}" . \
  --exclude-dir={node_modules,.git,venv,.next,dist,build}
```
Flag anything that isn't a placeholder or env var reference.

### 2. .env exposure
- `.env` files must be in `.gitignore`
- Run: `git ls-files | grep -i '\.env'` — if any .env is tracked, alert immediately
- Check for `.env.example` — should exist if `.env` is used, with placeholder values only

### 3. Git history leaks
```bash
git log --all --diff-filter=A --name-only --pretty=format: | grep -i 'env\|secret\|key\|credential' | sort -u
```
If secrets were ever committed, they're in history even if deleted.

### 4. Dependency vulnerabilities
- JS projects: `npm audit --json 2>/dev/null | head -50`
- Python projects: `pip audit 2>/dev/null || echo "pip-audit not installed"`

### 5. OWASP quick check
- **Injection:** Any raw SQL queries or string interpolation in queries?
- **Auth:** Are auth tokens validated on every protected route?
- **CORS:** Is CORS configured with specific origins (not `*` in production)?
- **Headers:** Security headers set? (CSP, X-Frame-Options, etc.)

### 6. Infrastructure
- Serverless / container services: service account has minimum permissions?
- Hosting platform: environment vars set in the dashboard, not in code?
- No `--allow-unauthenticated` (or equivalent public flag) on internal services?

## Gotchas

- **`grep` for secrets has false positives.** `API_KEY` in a TypeScript interface definition is not a leak. Check context before flagging.
- **Git history leaks persist after deletion.** If a secret was ever committed, `git filter-branch` or BFG Repo-Cleaner is needed. Just deleting the file doesn't remove it from history.
- **`npm audit` is noisy.** Many vulnerabilities are in dev dependencies or don't apply to your use case. Focus on `high` and `critical` in production dependencies.
- **CORS `*` in development is fine.** Only flag it if it's in production config or there's no env-based override.
- **Service account JSON files in repos are the most common real leak.** Always check for `serviceAccount.json`, `credentials.json`, `key.json` in tracked files.

## Output format

```
## Security Scan: [project name]
Date: YYYY-MM-DD

### Critical (fix before deploy)
- [ ] ...

### Warning (fix soon)
- [ ] ...

### Clean
- [x] No hardcoded secrets
- [x] .env not tracked
- [x] Dependencies up to date
```

If zero issues found, say so clearly. Don't invent problems.
