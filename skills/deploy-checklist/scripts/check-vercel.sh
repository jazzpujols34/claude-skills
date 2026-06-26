#!/bin/bash
# Vercel pre-deploy checks.
# Usage: bash scripts/check-vercel.sh [project-dir]

set -euo pipefail

DIR="${1:-.}"

echo "=== Vercel Checks ==="
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

# 2. vercel.json
echo "--- Checking vercel.json ---"
if [ -f "$DIR/vercel.json" ]; then
  echo "OK: vercel.json exists"
  cat "$DIR/vercel.json"
else
  echo "INFO: No vercel.json (using defaults)"
fi
echo ""

# 3. Co-Authored-By check (breaks Vercel free tier)
echo "--- Checking for Co-Authored-By in recent commits ---"
COAUTHOR=$(cd "$DIR" && git log --oneline -20 --format="%B" 2>/dev/null | grep -i "co-authored-by" || true)
if [ -n "$COAUTHOR" ]; then
  echo "WARN: Co-Authored-By found in recent commits — may block Vercel free tier deploys"
  echo "$COAUTHOR"
else
  echo "OK: No Co-Authored-By lines detected"
fi
echo ""

# 4. Framework detection
echo "--- Framework detection ---"
if [ -f "$DIR/vite.config.ts" ] || [ -f "$DIR/vite.config.js" ]; then
  echo "Detected: Vite — make sure Vercel framework preset is set to Vite, not Next.js"
elif [ -f "$DIR/next.config.js" ] || [ -f "$DIR/next.config.mjs" ] || [ -f "$DIR/next.config.ts" ]; then
  echo "Detected: Next.js"
else
  echo "INFO: Framework not auto-detected"
fi
echo ""

echo "=== Vercel checks complete ==="
