# claude-skills

![claude-skills — curated, drop-in skills for Claude Code](docs/cover.jpg)

**Skills for [Claude Code](https://claude.com/claude-code) (and other AI coding agents) that cover the whole arc of shipping a product — build, ship, grow.**

Each one was pulled from real production work, then stripped of anything personal so you can drop it into your own setup and it just works. No theory, no boilerplate to adapt — copy a folder and tell your agent what you want.

> **Self-contained.** One skill = one folder under `skills/`. No cross-dependencies, no private paths, no setup.

> **Last verified against Claude Code: 2026-06-27.** See [`CHANGELOG.md`](CHANGELOG.md) for what's changed.

## Install a skill

Pick one from the catalog below and copy its folder into your Claude Code skills directory:

```bash
cp -r skills/svg-diagram ~/.claude/skills/
```

That's the whole install. Then just describe the task in your own words — each skill's `SKILL.md` lists the phrases it listens for. No build step; skills are Markdown plus optional scripts.

## Catalog

Grouped by where they help — from your first commit to your first customers.

<!-- CATALOG:START -->
### Build
_Write, visualize, test, debug, review, and learn as you build._

| Skill | What it does | Tags | Maturity |
|---|---|---|---|
| [`annotate`](skills/annotate) | Add an inline-annotation layer to any HTML artifact so you can click/select parts of a plan, spec, review, or report and leave notes that copy back as a ready-t… | `html`, `review`, `annotation`, `feedback` | stable |
| [`debug-loop-breaker`](skills/debug-loop-breaker) | Use when debugging has gone in circles — same error 2+ times, repeated failed fixes. | `debugging`, `workflow`, `process` | stable |
| [`svg-diagram`](skills/svg-diagram) | Draw SVG diagrams inside HTML pages — flowcharts, decision trees, layer diagrams, architecture flows, tier matrices. | `html`, `svg`, `diagrams`, `data-viz`, `dark-mode` | stable |
| [`tdd-discipline`](skills/tdd-discipline) | Enforce test-first development. | `testing`, `tdd`, `workflow`, `quality` | stable |
| [`teaching-mode`](skills/teaching-mode) | Operating mode for coding sessions where the user wants to understand the work, not just receive it. | `teaching`, `learning`, `education`, `understanding` | stable |

### Ship
_Audit and deploy safely._

| Skill | What it does | Tags | Maturity |
|---|---|---|---|
| [`deploy-checklist`](skills/deploy-checklist) | Use before deploying any project to production. | `deploy`, `ci-cd`, `cloudflare`, `cloud-run`, `vercel`, `pre-deploy` | stable |
| [`security-scanner`](skills/security-scanner) | Use before any production deploy or when asked to audit security. | `security`, `secrets`, `audit`, `pre-deploy`, `owasp`, `dependencies` | stable |

### Grow
_Get found, get users, keep them._

| Skill | What it does | Tags | Maturity |
|---|---|---|---|
| [`growth-playbook`](skills/growth-playbook) | Post-launch marketing and growth. | `growth`, `marketing`, `cro`, `distribution`, `post-launch`, `email` | stable |
| [`seo-audit`](skills/seo-audit) | SEO audit and optimization for web projects. | `seo`, `schema`, `meta-tags`, `geo`, `web`, `content` | stable |
<!-- CATALOG:END -->

Maturity: `experimental` (new, may change) · `beta` (works, rough edges) · `stable` (battle-tested).

## Why these are different

- **Battle-tested, not theoretical.** Each skill earned its place fixing a real recurring problem across shipped projects — the `## Gotchas` in each one is the scar tissue.
- **Generic by gate, not by promise.** Every skill must pass `tools/check-skill.sh` before it ships: an automated scan for hardcoded secrets and for personalization (author names, private domains, machine paths). Nothing reaches you pointing at files that only exist on someone else's laptop.
- **Built for agents to read.** [`AGENTS.md`](AGENTS.md) and [`llms.txt`](llms.txt) describe the repo for AI tools; [`catalog.json`](catalog.json) is a machine-readable index, generated from the skills so it can't drift.

## How it's organized

```
claude-skills/
├── skills/<name>/        # each skill: SKILL.md + README.md + meta.json (+ scripts/refs)
├── _template/            # the contract a new skill starts from
├── tools/
│   ├── check-skill.sh    # publish gate: secrets + personalization scan
│   ├── new-skill.sh      # scaffold a new skill
│   └── build-catalog.py  # regenerate catalog.json + the table above
├── catalog.json          # generated index (don't hand-edit)
├── AGENTS.md · llms.txt  # for AI agents
└── CONTRIBUTING.md       # how to add a skill
```

## Add or contribute a skill

See [`CONTRIBUTING.md`](CONTRIBUTING.md). In short: `tools/new-skill.sh <name>`, write it, pass `tools/check-skill.sh`, run `tools/build-catalog.py`. The collection is meant to keep growing.

## Maintenance

This isn't a content feed — it grows when there's something genuinely worth adding, and stays correct in between:

- **New skills land organically.** When a skill proves itself across real projects, it goes through the pipeline above. Quality bar over count.
- **Re-verified against Claude Code monthly.** Claude Code moves fast, so the skills and their scripts are re-checked against the current release and the "Last verified" date at the top is bumped.
- **Gotchas come from use.** Each skill's `## Gotchas` grows as real edge cases surface.

## Related

- **[post-to-visual](https://github.com/jazzpujols34/post-to-visual)** — a deeper standalone skill: turn an article into an illustrated, single-file HTML page.
- **[claude-code-workflow](https://github.com/jazzpujols34/claude-code-workflow)** — the conventions/templates layer (CLAUDE.md, handover, memory) that makes context compound across sessions.

## License

[MIT](LICENSE). The skills are yours to adapt — review before redistributing verbatim.
