#!/bin/bash
# Cloudflare Pages pre-deploy checks.
# Usage: bash scripts/check-cf.sh [project-dir]

set -euo pipefail

DIR="${1:-.}"

echo "=== Cloudflare Pages Checks ==="
echo ""

# 1. Build
echo "--- Build check ---"
if [ -f "$DIR/package.json" ]; then
  echo "Running: npm run build"
  (cd "$DIR" && npm run build 2>&1) || { echo "FAIL: Build failed"; exit 1; }
  echo "OK: Build succeeded"
else
  echo "SKIP: No package.json"
fi
echo ""

# 2. Node server APIs (edge runtime incompatible)
echo "--- Checking for Node server APIs (edge-incompatible) ---"
NODE_APIS=$(grep -rn "require\s*(\s*['\"]fs['\"])\|require\s*(\s*['\"]child_process['\"])\|from\s*['\"]fs['\"]" "$DIR" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=scripts \
  2>/dev/null || true)
if [ -n "$NODE_APIS" ]; then
  echo "WARN: Node server APIs found (not compatible with edge runtime):"
  echo "$NODE_APIS"
else
  echo "OK: No Node server APIs detected"
fi
echo ""

# 3. wrangler.toml
echo "--- Checking wrangler.toml ---"
if [ -f "$DIR/wrangler.toml" ]; then
  echo "OK: wrangler.toml exists"
  if grep -q "compatibility_date" "$DIR/wrangler.toml"; then
    COMPAT_DATE=$(grep "compatibility_date" "$DIR/wrangler.toml" | head -1)
    echo "  $COMPAT_DATE"
  else
    echo "WARN: No compatibility_date set"
  fi
else
  echo "WARN: No wrangler.toml found"
fi
echo ""

# 4. next.config check
echo "--- Checking next.config ---"
NEXT_CONFIG=$(find "$DIR" -maxdepth 1 -name "next.config.*" 2>/dev/null | head -1)
if [ -n "$NEXT_CONFIG" ]; then
  if grep -q "standalone" "$NEXT_CONFIG"; then
    echo "CRITICAL: output: 'standalone' found in $NEXT_CONFIG — incompatible with CF Pages"
  else
    echo "OK: No standalone output mode"
  fi
else
  echo "SKIP: Not a Next.js project"
fi
echo ""

echo "=== CF Pages checks complete ==="
