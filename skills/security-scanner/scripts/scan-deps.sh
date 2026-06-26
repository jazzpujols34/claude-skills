#!/bin/bash
# Scan for dependency vulnerabilities.
# Usage: bash scan-deps.sh [project-dir]   (defaults to current directory)

set -euo pipefail

DIR="${1:-.}"

echo "=== Dependency Vulnerability Scan ==="
echo "Directory: $DIR"
echo ""

# JavaScript / npm
if [ -f "$DIR/package-lock.json" ] || [ -f "$DIR/package.json" ]; then
  echo "--- npm audit ---"
  (cd "$DIR" && npm audit --omit=dev 2>&1) || true
  echo ""
fi

# Python / pip
if [ -f "$DIR/requirements.txt" ] || [ -f "$DIR/pyproject.toml" ]; then
  echo "--- pip-audit ---"
  if command -v pip-audit &>/dev/null; then
    (cd "$DIR" && pip-audit 2>&1) || true
  else
    echo "SKIP: pip-audit not installed (pip install pip-audit)"
  fi
  echo ""
fi

echo "=== Dependency scan complete ==="
