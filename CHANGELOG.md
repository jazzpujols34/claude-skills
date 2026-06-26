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
- **svg-diagram** — first skill: precise, light/dark-safe SVG diagrams inside HTML,
  with layout math that prevents text collisions and viewBox bugs.
