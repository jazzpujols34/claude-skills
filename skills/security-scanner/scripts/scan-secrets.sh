#!/bin/bash
# Scan for hardcoded secrets, tracked .env files, and git history leaks.
# Usage: bash scan-secrets.sh [project-dir]   (defaults to current directory)

set -euo pipefail

DIR="${1:-.}"
ISSUES=0

echo "=== Secret Scan ==="
echo "Directory: $DIR"
echo ""

# 1. Hardcoded secrets in code
echo "--- Hardcoded secrets in code ---"
SECRETS=$(grep -rn --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --include="*.py" --include="*.json" --include="*.yaml" --include="*.yml" --include="*.toml" --include="*.sh" \
  -E "(api[_-]?key|secret|password|token|credential|private[_-]?key)\s*[:=]\s*['\"][^'\"]{8,}" "$DIR" \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=venv --exclude-dir=.next --exclude-dir=dist --exclude-dir=build --exclude-dir=__pycache__ \
  2>/dev/null || true)

if [ -n "$SECRETS" ]; then
  echo "WARN: Possible hardcoded secrets:"
  echo "$SECRETS"
  echo ""
  echo "(Review each match — interface definitions and placeholders are false positives)"
  ISSUES=$((ISSUES + 1))
else
  echo "OK: No hardcoded secrets detected"
fi
echo ""

# 2. .env files tracked in git
echo "--- Tracked .env files ---"
TRACKED_ENV=$(cd "$DIR" && git ls-files 2>/dev/null | grep -iE '\.env$|\.env\.local$|\.env\.production$' || true)
if [ -n "$TRACKED_ENV" ]; then
  echo "CRITICAL: .env files tracked in git:"
  echo "$TRACKED_ENV"
  ISSUES=$((ISSUES + 1))
else
  echo "OK: No .env files in git"
fi
echo ""

# 3. Service account / credential JSON files
echo "--- Credential JSON files ---"
CRED_FILES=$(cd "$DIR" && git ls-files 2>/dev/null | grep -iE "serviceaccount|credentials|key\.json|service[_-]?account" || true)
if [ -n "$CRED_FILES" ]; then
  echo "CRITICAL: Credential files tracked in git:"
  echo "$CRED_FILES"
  ISSUES=$((ISSUES + 1))
else
  echo "OK: No credential JSON files in git"
fi
echo ""

# 4. Git history leaks
echo "--- Git history leak check ---"
HISTORY_LEAKS=$(cd "$DIR" && git log --all --diff-filter=A --name-only --pretty=format: 2>/dev/null | grep -iE '\.env|secret|key\.json|credential|serviceaccount' | sort -u || true)
if [ -n "$HISTORY_LEAKS" ]; then
  echo "WARN: Sensitive-looking files were added to git history at some point:"
  echo "$HISTORY_LEAKS"
  echo "(Even if deleted, they're still in history. Use BFG or git filter-branch to purge.)"
  ISSUES=$((ISSUES + 1))
else
  echo "OK: No sensitive files found in git history"
fi
echo ""

echo "=== Secret scan complete: $ISSUES issue(s) found ==="
exit $ISSUES
