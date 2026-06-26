#!/usr/bin/env python3
"""build-catalog.py — regenerate the skill index from the skills themselves.

The catalog is *generated*, never hand-maintained, so it can't drift from the
skills it describes. Run it after adding or editing a skill:

    python3 tools/build-catalog.py

It reads each skills/<name>/SKILL.md frontmatter (name, description) plus an
optional skills/<name>/meta.json (tags, maturity, version), then writes:
  - catalog.json                    (machine-readable index, for agents/tools)
  - the table between <!-- CATALOG:START --> and <!-- CATALOG:END --> in README.md

Output is deterministic (no timestamps) so re-running produces no spurious diff.
Pure standard library.
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKILLS = ROOT / "skills"


def parse_frontmatter(md_path: Path) -> dict:
    """Minimal YAML-frontmatter reader for flat `key: value` scalars."""
    text = md_path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    if end == -1:
        return {}
    block = text[3:end]
    out = {}
    for line in block.splitlines():
        if ":" in line and not line.startswith(" "):
            k, _, v = line.partition(":")
            out[k.strip()] = v.strip()
    return out


def load_skill(d: Path) -> dict | None:
    skill_md = d / "SKILL.md"
    if not skill_md.is_file():
        return None
    fm = parse_frontmatter(skill_md)
    meta = {}
    meta_path = d / "meta.json"
    if meta_path.is_file():
        try:
            meta = json.loads(meta_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as e:
            print(f"  warn: {d.name}/meta.json is invalid JSON ({e})", file=sys.stderr)
    return {
        "name": fm.get("name", d.name),
        "description": fm.get("description", "").strip(),
        "tags": meta.get("tags", []),
        "phase": meta.get("phase", ""),
        "maturity": meta.get("maturity", "experimental"),
        "version": meta.get("version", "0.1.0"),
        "path": f"skills/{d.name}",
    }


# Lifecycle phases, in order. A skill's meta.json `phase` slots it into one of these
# groups in the README; anything unset (or unknown) lands under "More".
PHASES = [
    ("build", "Build", "Write, visualize, and debug your code."),
    ("ship", "Ship", "Audit and deploy safely."),
    ("grow", "Grow", "Get found, get users, keep them."),
]


def short(desc: str, limit: int = 160) -> str:
    """First sentence (or `limit` chars) of a description, for the table cell."""
    desc = desc.replace("|", "\\|").strip()
    for stop in (". ", "。"):
        i = desc.find(stop)
        if 0 < i < limit:
            return desc[: i + 1].strip()
    return (desc[:limit] + "…") if len(desc) > limit else desc


def main() -> int:
    skills = []
    for d in sorted(SKILLS.iterdir()) if SKILLS.is_dir() else []:
        if not d.is_dir():
            continue
        s = load_skill(d)
        if s:
            skills.append(s)

    catalog = {"count": len(skills), "skills": skills}
    (ROOT / "catalog.json").write_text(
        json.dumps(catalog, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    # Build the README catalog, grouped by lifecycle phase.
    def render_table(group: list) -> str:
        out = ["| Skill | What it does | Tags | Maturity |", "|---|---|---|---|"]
        for s in sorted(group, key=lambda x: x["name"]):
            tags = ", ".join(f"`{t}`" for t in s["tags"]) or "—"
            out.append(
                f"| [`{s['name']}`]({s['path']}) | {short(s['description'])} | {tags} | {s['maturity']} |"
            )
        return "\n".join(out)

    known = {key for key, _, _ in PHASES}
    sections = []
    for key, label, blurb in PHASES:
        group = [s for s in skills if s["phase"] == key]
        if group:
            sections.append(f"### {label}\n_{blurb}_\n\n{render_table(group)}")
    leftover = [s for s in skills if s["phase"] not in known]
    if leftover:
        sections.append(f"### More\n\n{render_table(leftover)}")
    table = "\n\n".join(sections)

    readme = ROOT / "README.md"
    if readme.is_file():
        text = readme.read_text(encoding="utf-8")
        a, b = "<!-- CATALOG:START -->", "<!-- CATALOG:END -->"
        if a in text and b in text:
            pre = text[: text.index(a) + len(a)]
            post = text[text.index(b):]
            readme.write_text(f"{pre}\n{table}\n{post}", encoding="utf-8")
        else:
            print("  warn: README.md has no CATALOG markers; skipped table inject", file=sys.stderr)

    print(f"catalog: {len(skills)} skill(s) -> catalog.json + README table")
    for s in skills:
        print(f"  - {s['name']}  ({s['maturity']})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
