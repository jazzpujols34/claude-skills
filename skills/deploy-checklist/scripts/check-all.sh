#!/bin/bash
# Universal pre-deploy checks — run before any platform-specific checks.
# Usage: bash scripts/check-all.sh [project-dir]

set -euo pipefail

DIR="${1:-.}"
FAIL=0

echo "=== Universal Pre-Deploy Checks ==="
echo "Directory: $DIR"
echo ""

# 1. Secrets in code
echo "--- Checking for hardcoded secrets ---"
SECRETS=$(grep -rn --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --include="*.py" --include="*.json" --include="*.yaml" --include="*.yml" \
  -E "(api[_-]?key|secret|password|token|credential|private[_-]?key)\s*[:=]\s*['\"][^'\"]{8,}" "$DIR" \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=venv --exclude-dir=.next --exclude-dir=dist --exclude-dir=build \
  2>/dev/null || true)

if [ -n "$SECRETS" ]; then
  echo "WARN: Possible hardcoded secrets found:"
  echo "$SECRETS"
  FAIL=1
else
  echo "OK: No hardcoded secrets detected"
fi
echo ""

# 2. .env tracked in git
echo "--- Checking for tracked .env files ---"
TRACKED_ENV=$(cd "$DIR" && git ls-files 2>/dev/null | grep -i '\.env$' || true)
if [ -n "$TRACKED_ENV" ]; then
  echo "CRITICAL: .env files tracked in git:"
  echo "$TRACKED_ENV"
  FAIL=1
else
  echo "OK: No .env files in git"
fi
echo ""

# 3. .gitignore coverage
echo "--- Checking .gitignore ---"
GITIGNORE="$DIR/.gitignore"
if [ -f "$GITIGNORE" ]; then
  MISSING=""
  for PATTERN in node_modules dist build .env __pycache__ .wrangler venv; do
    if ! grep -q "$PATTERN" "$GITIGNORE" 2>/dev/null; then
      MISSING="$MISSING $PATTERN"
    fi
  done
  if [ -n "$MISSING" ]; then
    echo "WARN: Missing from .gitignore:$MISSING"
  else
    echo "OK: .gitignore covers standard patterns"
  fi
else
  echo "WARN: No .gitignore found"
fi
echo ""

# 4. Console.logs in production code
echo "--- Checking for console.log ---"
CONSOLELOGS=$(grep -rn "console\.log" "$DIR" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=build --exclude-dir=__tests__ \
  2>/dev/null | head -10 || true)
if [ -n "$CONSOLELOGS" ]; then
  echo "WARN: console.log found in production code:"
  echo "$CONSOLELOGS"
else
  echo "OK: No console.logs in production code"
fi
echo ""

# 5. Tests
echo "--- Running tests ---"
if [ -f "$DIR/package.json" ]; then
  if grep -q '"test"' "$DIR/package.json"; then
    echo "Running: npm test"
    (cd "$DIR" && npm test 2>&1) || FAIL=1
  else
    echo "SKIP: No test script in package.json"
  fi
elif [ -f "$DIR/pytest.ini" ] || [ -f "$DIR/setup.py" ] || [ -f "$DIR/pyproject.toml" ]; then
  echo "Running: pytest"
  (cd "$DIR" && pytest 2>&1) || FAIL=1
else
  echo "SKIP: No test runner detected"
fi
echo ""

echo "=== Done ==="
if [ $FAIL -ne 0 ]; then
  echo "STATUS: ISSUES FOUND — review above before deploying"
  exit 1
else
  echo "STATUS: ALL CLEAR"
  exit 0
fi
