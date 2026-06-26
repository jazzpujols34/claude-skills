# Changelog

All notable changes to this collection. Format loosely follows
[Keep a Changelog](https://keepachangelog.com). Skills are versioned individually
in their `meta.json`; this log tracks the repo.

## [Unreleased]

### Added
- Repo scaffold: per-skill `skills/<name>/` layout, `_template/` contract,
  `AGENTS.md` + `llms.txt` for agents, generated `catalog.json`.
- Tooling: `tools/check-skill.sh` (secret + personalization publish gate),
  `tools/new-skill.sh` (scaffold), `tools/build-catalog.py` (generated index).
- **svg-diagram** — precise, light/dark-safe SVG diagrams inside HTML, with layout
  math that prevents text collisions and viewBox bugs.
- **debug-loop-breaker** — breaks the "same error 2+ times" debugging spiral with a
  systematic diagnosis protocol instead of more guessing.
- **security-scanner** — pre-deploy scan for hardcoded secrets, exposed `.env`, git
  history leaks, dependency vulns, and OWASP issues (ships 3 standalone scripts).
- **deploy-checklist** — auto-detects the platform (Cloudflare Pages / Cloud Run /
  Vercel) and runs platform-specific pre-deploy checks (ships 4 standalone scripts).
- **tdd-guard** — enforces test-first development; pairs with debug-loop-breaker
  (prevention vs. cure).
- **growth-playbook** — the after-you-ship skill: positioning, landing-page audit,
  CRO, distribution, email sequences, churn prevention.
- **seo-audit** — technical SEO + content audit + schema markup + GEO (optimizing
  for AI search).
