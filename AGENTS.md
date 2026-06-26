# AGENTS.md

Guidance for AI coding agents (Claude Code, Cursor, and others) working with this
repo. Humans: start with [`README.md`](README.md). This file follows the
[agents.md](https://agents.md) convention.

## What this repo is

A curated collection of **self-contained Claude Code skills**. Each skill lives in
`skills/<name>/` and is independent — no skill depends on another, and none depends
on anything outside its own folder. You can copy any one folder into a
`~/.claude/skills/` directory and it works on its own.

## Discover what's here

- **`catalog.json`** — the machine-readable index. Parse it to list every skill with
  its name, description, tags, maturity, and path. It is generated from the skills
  themselves, so it never drifts.
- **`skills/<name>/SKILL.md`** — the skill's own instructions. The frontmatter
  `description` is the routing signal (when to trigger); the body is the procedure.

## Use a skill

1. Read its `skills/<name>/SKILL.md` and follow the procedure there.
2. If it references files (`references/…`, `scripts/…`), they are inside that same
   skill folder. Paths in a SKILL.md are **relative to the skill folder** — never an
   absolute machine path.
3. If the skill ships scripts, run them with the command shown in its SKILL.md.

## Install a skill (for the user)

```bash
cp -r skills/<name> ~/.claude/skills/
```
That's the whole install. No build step. Skills are plain Markdown (+ optional
scripts/assets).

## The skill contract — invariants every skill in this repo holds

1. **Self-contained.** Everything the skill needs is inside its folder.
2. **No personalization.** No author names, private domains, private project names,
   or machine-local paths. Enforced by `tools/check-skill.sh`.
3. **Portable paths.** References are relative to the skill folder.
4. **A `SKILL.md` with frontmatter** (`name`, `description`) is mandatory; a
   `README.md` (human) and `meta.json` (tags/maturity) are expected.
5. **Gotchas live in the skill.** Hard-won edge cases go in the skill's own
   `## Gotchas`, not in tribal memory.

## Editing or adding a skill

See [`CONTRIBUTING.md`](CONTRIBUTING.md). The short version:

```bash
tools/new-skill.sh <name>          # scaffold from _template/
# ...write SKILL.md / README.md / meta.json...
tools/check-skill.sh skills/<name> # MUST pass — no secrets, no personalization
python3 tools/build-catalog.py     # regenerate catalog.json + the README table
```

Never edit the catalog table in `README.md` by hand — it is generated.
