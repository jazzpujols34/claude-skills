# Contributing a skill

This repo grows one skill at a time. The bar is: **self-contained, generic, and
genuinely better than an ad-hoc prompt.** A skill that only makes sense on the
author's machine doesn't belong here.

## Add a skill

```bash
tools/new-skill.sh my-skill        # scaffolds skills/my-skill/ from _template/
```

Then fill in:

- **`SKILL.md`** — the instructions an agent follows. Frontmatter `name` +
  `description` are required. The `description` is the routing signal: lead with the
  job, list trigger phrases, say what it's NOT for.
- **`README.md`** — the human quickstart: what it does, how to install, one example.
- **`meta.json`** — `tags`, `phase` (`build` / `ship` / `grow` — which lifecycle
  group it lands in on the README; leave empty to fall under "More"), `maturity`
  (`experimental` / `beta` / `stable`), `version`, and any `requires` (e.g. a runtime
  or API key).

## The publish gate (required)

```bash
tools/check-skill.sh skills/my-skill
```

It must report **PASS**. It fails on:

1. **Secrets** — API keys, tokens, private keys, committed `.env`/`.pem`/credential files.
2. **Personalization** — author names, private domains, private project names, or
   machine-local paths (`/Users/...`, monorepo paths, `.claude/skills/<x>` absolutes).
   The list lives in `tools/personal-denylist.txt`; extend it with genuinely-generic
   terms — never silence a real leak.
3. **Contract** — a `SKILL.md` with valid frontmatter must exist.

## Refresh the catalog

```bash
python3 tools/build-catalog.py
```

This regenerates `catalog.json` and the table in `README.md`. **Don't hand-edit the
table** — it's generated, so it can't rot.

## Checklist before you open a PR / commit

- [ ] Skill is self-contained (no references outside its own folder)
- [ ] All paths in SKILL.md are relative to the skill folder
- [ ] `tools/check-skill.sh skills/<name>` passes
- [ ] `python3 tools/build-catalog.py` run and committed
- [ ] `CHANGELOG.md` updated
- [ ] Any scripts run standalone (documented runtime/deps)
