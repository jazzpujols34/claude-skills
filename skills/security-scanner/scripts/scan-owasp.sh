#!/bin/bash
# Quick OWASP top-10 pattern check.
# Usage: bash scan-owasp.sh [project-dir]   (defaults to current directory)

set -euo pipefail

DIR="${1:-.}"
ISSUES=0

echo "=== OWASP Quick Check ==="
echo "Directory: $DIR"
echo ""

# 1. SQL Injection — raw string interpolation in queries
echo "--- SQL Injection patterns ---"
SQL_INJECT=$(grep -rn --include="*.py" --include="*.ts" --include="*.js" \
  -E "f['\"].*SELECT.*\{|f['\"].*INSERT.*\{|f['\"].*UPDATE.*\{|f['\"].*DELETE.*\{|\\.format\(.*SELECT|\.format\(.*INSERT" "$DIR" \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=venv \
  2>/dev/null || true)
if [ -n "$SQL_INJECT" ]; then
  echo "WARN: Possible SQL injection (string interpolation in queries):"
  echo "$SQL_INJECT"
  ISSUES=$((ISSUES + 1))
else
  echo "OK: No obvious SQL injection patterns"
fi
echo ""

# 2. CORS wildcard in production
echo "--- CORS wildcard check ---"
CORS_WILD=$(grep -rn --include="*.py" --include="*.ts" --include="*.js" \
  -E "cors.*\*|allow_origins.*\[.*\"\*\"|Access-Control-Allow-Origin.*\*" "$DIR" \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=venv \
  2>/dev/null || true)
if [ -n "$CORS_WILD" ]; then
  echo "WARN: CORS wildcard (*) found — check if this is production config:"
  echo "$CORS_WILD"
  ISSUES=$((ISSUES + 1))
else
  echo "OK: No CORS wildcard detected"
fi
echo ""

# 3. Missing auth on routes
echo "--- Unprotected route patterns ---"
UNPROTECTED=$(grep -rn --include="*.py" --include="*.ts" --include="*.js" \
  -E "@app\.(get|post|put|delete|patch)\(|router\.(get|post|put|delete|patch)\(" "$DIR" \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=venv \
  2>/dev/null | head -20 || true)
if [ -n "$UNPROTECTED" ]; then
  echo "INFO: Route definitions found (manually verify auth middleware):"
  echo "$UNPROTECTED"
  echo "(This is informational — not all routes need auth)"
else
  echo "OK: No route definitions found to check"
fi
echo ""

# 4. Dangerous eval/exec
echo "--- Dangerous eval/exec ---"
EVAL=$(grep -rn --include="*.py" --include="*.ts" --include="*.js" \
  -E "\beval\s*\(|\bexec\s*\(" "$DIR" \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=venv \
  2>/dev/null || true)
if [ -n "$EVAL" ]; then
  echo "WARN: eval/exec found:"
  echo "$EVAL"
  ISSUES=$((ISSUES + 1))
else
  echo "OK: No eval/exec calls"
fi
echo ""

echo "=== OWASP check complete: $ISSUES issue(s) found ==="
exit $ISSUES
