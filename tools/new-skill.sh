#!/usr/bin/env bash
# new-skill.sh — scaffold a new skill folder from _template/.
#
# Usage: tools/new-skill.sh <skill-name>
#   e.g. tools/new-skill.sh debug-loop-breaker
#
# Creates skills/<skill-name>/ with SKILL.md, README.md, and meta.json stubs.
# Then: fill them in, run tools/check-skill.sh skills/<name>, then
# tools/build-catalog.py to refresh the catalog.

set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

name="${1:-}"
if [ -z "$name" ]; then
  echo "usage: tools/new-skill.sh <skill-name>" >&2
  exit 1
fi
if ! printf '%s' "$name" | grep -qE '^[a-z0-9][a-z0-9-]*$'; then
  echo "skill name must be kebab-case (a-z, 0-9, -): got '$name'" >&2
  exit 1
fi

dest="$ROOT/skills/$name"
if [ -e "$dest" ]; then
  echo "skills/$name already exists." >&2
  exit 1
fi

cp -R "$ROOT/_template" "$dest"
# substitute the placeholder name into the stubs
for f in SKILL.md README.md meta.json; do
  if [ -f "$dest/$f" ]; then
    sed "s/SKILL_NAME/$name/g" "$dest/$f" > "$dest/$f.tmp" && mv "$dest/$f.tmp" "$dest/$f"
  fi
done

echo "Scaffolded skills/$name"
echo "Next:"
echo "  1. Write skills/$name/SKILL.md (the instructions Claude follows)"
echo "  2. Fill skills/$name/README.md + meta.json"
echo "  3. tools/check-skill.sh skills/$name   # must pass"
echo "  4. tools/build-catalog.py              # refresh the catalog"
