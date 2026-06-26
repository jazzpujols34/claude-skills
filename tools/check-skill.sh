#!/usr/bin/env bash
# check-skill.sh — the publish gate for claude-skills.
#
# Scans a skill folder (or every skill) for the three things that must never
# ship: hardcoded secrets, committed env/key files, and personalization that
# points readers at private people / machines / projects.
#
# Usage:
#   tools/check-skill.sh                 # scan every skill under skills/
#   tools/check-skill.sh skills/svg-diagram
#
# Exit code 0 = clean, 1 = findings (suitable for CI / pre-commit).

set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DENYLIST="$ROOT/tools/personal-denylist.txt"

targets=()
if [ "$#" -ge 1 ]; then
  targets=("$@")
else
  for d in "$ROOT"/skills/*/; do [ -d "$d" ] && targets+=("$d"); done
fi

if [ "${#targets[@]}" -eq 0 ]; then
  echo "No skills to check (skills/ is empty)."
  exit 0
fi

fail=0
red()  { printf '\033[31m%s\033[0m\n' "$1"; }
grn()  { printf '\033[32m%s\033[0m\n' "$1"; }
dim()  { printf '\033[2m%s\033[0m\n'  "$1"; }

# Secret patterns — high-signal, low false-positive.
SECRET_RE='(AKIA[0-9A-Z]{16}|sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{20,}|gho_[a-zA-Z0-9]{20,}|AIza[0-9A-Za-z_-]{30,}|xox[baprs]-[0-9A-Za-z-]{10,}|-----BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY-----|client_secret["'"'"']?\s*[:=]|aws_secret_access_key)'

for t in "${targets[@]}"; do
  t="${t%/}"
  name="$(basename "$t")"
  echo "── $name"
  hits=0

  # 1. committed secret/key files
  while IFS= read -r f; do
    red "  secret-file: $f"; hits=$((hits+1))
  done < <(find "$t" -type f \( -name "*.env" -o -name "*.key" -o -name "*.pem" -o -name "id_rsa*" -o -name "*-credentials.json" \) 2>/dev/null)

  # 2. secret-looking strings in tracked text
  while IFS= read -r line; do
    [ -n "$line" ] && { red "  secret-string: $line"; hits=$((hits+1)); }
  done < <(grep -rInaE "$SECRET_RE" "$t" 2>/dev/null | grep -viE 'GEMINI_API_KEY|YOUR_|<your|example|\$\{' | head -40)

  # 3. personalization deny-list
  while IFS= read -r pat; do
    case "$pat" in ''|\#*) continue;; esac
    while IFS= read -r line; do
      [ -n "$line" ] && { red "  personal:  [$pat] $line"; hits=$((hits+1)); }
    done < <(grep -rInaiE "$pat" "$t" 2>/dev/null | head -10)
  done < "$DENYLIST"

  # 4. structural contract — a skill must have a SKILL.md with frontmatter
  if [ ! -f "$t/SKILL.md" ]; then
    red "  missing:   SKILL.md"; hits=$((hits+1))
  else
    head -1 "$t/SKILL.md" | grep -q '^---' || { red "  malformed: SKILL.md has no frontmatter"; hits=$((hits+1)); }
    grep -q '^name:' "$t/SKILL.md"        || { red "  malformed: SKILL.md frontmatter missing name:"; hits=$((hits+1)); }
    grep -q '^description:' "$t/SKILL.md"  || { red "  malformed: SKILL.md frontmatter missing description:"; hits=$((hits+1)); }
  fi

  if [ "$hits" -eq 0 ]; then grn "  clean"; else fail=$((fail+hits)); fi
done

echo
if [ "$fail" -eq 0 ]; then
  grn "PASS — 0 findings. Safe to publish."
  exit 0
else
  red "FAIL — $fail finding(s). Fix before publishing."
  dim "(Add genuinely-generic terms to tools/personal-denylist.txt; never silence a real leak.)"
  exit 1
fi
