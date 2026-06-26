# security-scanner

> A pre-deploy security sweep: catch hardcoded secrets, tracked `.env` files, git-history leaks, vulnerable dependencies, and common OWASP foot-guns before they ship.

**What it does.** Gives an AI agent (or you) a repeatable security audit made of three standalone shell scripts plus a manual checklist. The scripts grep for secret-shaped strings, check git for tracked credential files and history leaks, run `npm audit` / `pip-audit`, and flag SQL-injection, CORS-wildcard, and `eval`/`exec` patterns. The skill's value is the curated patterns and the gotchas that keep false positives from drowning the real findings.

**Install.** Copy the folder into your Claude Code skills directory:
```bash
cp -r skills/security-scanner ~/.claude/skills/
```
Then trigger it in your own words — "run a security scan", "check for secrets", "audit security" — or before any deploy. The skill listens for those phrases (see the `description` in [`SKILL.md`](SKILL.md)).

**Run the scripts directly.** Each takes an optional project directory (defaults to the current directory):
```bash
bash scripts/scan-secrets.sh ./path/to/project   # secrets, tracked .env, credential JSONs, git history
bash scripts/scan-deps.sh    ./path/to/project   # npm audit + pip-audit
bash scripts/scan-owasp.sh   ./path/to/project   # SQL injection, CORS *, eval/exec, route auth
```
Each script exits non-zero with the count of issues found, so they slot into CI or a pre-commit hook.

**Dependencies.** `bash` and `git` (already present in most dev environments). `scan-deps.sh` uses `npm` for JS projects and `pip-audit` for Python projects — both are optional and skipped gracefully if not installed (`pip install pip-audit` to enable the Python check). No API key required.
