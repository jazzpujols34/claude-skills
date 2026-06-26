#!/bin/bash
# Cloud Run pre-deploy checks.
# Usage: bash scripts/check-cr.sh [project-dir]

set -euo pipefail

DIR="${1:-.}"

echo "=== Cloud Run Checks ==="
echo ""

# 1. Dockerfile
echo "--- Checking Dockerfile ---"
if [ -f "$DIR/Dockerfile" ]; then
  echo "OK: Dockerfile exists"

  # Port check
  EXPOSE_PORT=$(grep -i "^EXPOSE" "$DIR/Dockerfile" | head -1 | grep -oE "[0-9]+" || echo "none")
  CMD_LINE=$(grep -i "^CMD\|^ENTRYPOINT" "$DIR/Dockerfile" | tail -1)
  echo "  EXPOSE port: $EXPOSE_PORT"
  echo "  CMD/ENTRYPOINT: $CMD_LINE"

  if [ "$EXPOSE_PORT" != "8080" ] && [ "$EXPOSE_PORT" != "none" ]; then
    echo "  WARN: Port is $EXPOSE_PORT, Cloud Run defaults to 8080. Make sure --port flag matches."
  fi
else
  echo "WARN: No Dockerfile found. Using --source deploy?"
fi
echo ""

# 2. Docker build test
echo "--- Docker build test ---"
if [ -f "$DIR/Dockerfile" ] && command -v docker &>/dev/null; then
  echo "Running: docker build (dry run)"
  (cd "$DIR" && docker build -t deploy-check-tmp . 2>&1) && echo "OK: Docker build succeeded" || echo "FAIL: Docker build failed"
  docker rmi deploy-check-tmp 2>/dev/null || true
else
  echo "SKIP: No Dockerfile or Docker not available"
fi
echo ""

# 3. Health endpoint
echo "--- Checking for health endpoint ---"
HEALTH=$(grep -rn "health\|/health\|healthz" "$DIR" \
  --include="*.py" --include="*.ts" --include="*.js" \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=venv \
  2>/dev/null | head -5 || true)
if [ -n "$HEALTH" ]; then
  echo "OK: Health endpoint references found:"
  echo "$HEALTH"
else
  echo "WARN: No health endpoint detected. Cloud Run needs one for startup probes."
fi
echo ""

# 4. Region check (remind)
echo "--- Region reminder ---"
echo "Set an explicit region with --region (e.g. asia-east1)."
echo "Use: gcloud run deploy SERVICE --region <your-region>"
echo "If a service can't be found later, check the region first."
echo ""

echo "=== Cloud Run checks complete ==="
