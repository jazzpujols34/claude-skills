---
name: deploy-checklist
description: Use before deploying any project to production. Auto-detects platform (Cloudflare Pages, Cloud Run, Vercel) and runs platform-specific checks. Trigger on "deploy", "deploy checklist", "push to prod".
---

# Skill: Deploy Checklist

> Platform-specific pre-deploy checks. Triggered by "deploy checklist" or before any production deploy.

## Scripts

This skill includes executable scripts for automated checks. Run them instead of manually checking. All paths are relative to this skill folder.

| Script | Purpose |
|--------|---------|
| `scripts/check-all.sh [dir]` | Universal checks: secrets, .env, .gitignore, console.logs, tests |
| `scripts/check-cf.sh [dir]` | Cloudflare Pages: build, edge API usage, wrangler.toml, next.config |
| `scripts/check-cr.sh [dir]` | Cloud Run: Dockerfile, port matching, health endpoint, Docker build |
| `scripts/check-vercel.sh [dir]` | Vercel: build, vercel.json, Co-Authored-By, framework detection |

**Workflow:** Run `check-all.sh` first, then the platform-specific script.

```bash
bash scripts/check-all.sh ./your-project
bash scripts/check-cf.sh ./your-project
```

## Step 1: Detect the Platform

Auto-detect from files present in the project, then run the matching checks:

| Signal in the project | Likely platform |
|-----------------------|-----------------|
| `wrangler.toml`, `@cloudflare/next-on-pages`, `.vercel/output/static` | Cloudflare Pages |
| `Dockerfile` + `gcloud`/`cloudbuild.yaml`, or a Python/FastAPI service | Cloud Run |
| `vercel.json`, `.vercel/`, a Vite/Next SPA with no Dockerfile | Vercel |

If the signals are ambiguous (e.g. a repo with both a frontend on one platform and a backend on another), ask which platform you're deploying.

## Step 2: All Platforms (Run First)

- [ ] **No secrets in code**: `grep -rn "API_KEY\|SECRET\|PASSWORD\|sk-\|PRIVATE_KEY" --include="*.ts" --include="*.py" --include="*.js" --include="*.env"` — only `.env` files should match
- [ ] **Tests pass**: `npm test` or `pytest`
- [ ] **.gitignore covers**: `node_modules/`, `dist/`, `build/`, `.env`, `__pycache__/`, `.wrangler/`
- [ ] **No console.logs** in production code
- [ ] **README has deploy instructions**

## Step 3: Platform-Specific Checks

### Cloudflare Pages

- [ ] `npm run build` succeeds locally
- [ ] No Node server APIs (`fs`, `path`, `child_process`) — edge runtime only
- [ ] Check `wrangler.toml` exists and `compatibility_date` is recent
- [ ] Environment vars set in **Cloudflare dashboard → Settings → Environment variables**
- [ ] If using D1/R2/KV: bindings declared in `wrangler.toml`
- [ ] `next.config.js` has no `output: 'standalone'` (incompatible with CF Pages)

```bash
# Quick validation
npm run build
npx wrangler pages dev .vercel/output/static  # local CF preview
```

### Cloud Run

- [ ] `Dockerfile` exists and builds: `docker build -t test-deploy .`
- [ ] Or `gcloud builds submit` config ready (cloudbuild.yaml / inline)
- [ ] `.env` vars mapped to Cloud Run environment or Secret Manager
- [ ] Service account has required permissions (storage, firestore, etc.)
- [ ] Region set explicitly (e.g. `asia-east1`, or whichever region you standardize on)
- [ ] Port matches `CMD` in Dockerfile and Cloud Run config (default 8080)
- [ ] Health check endpoint exists (`/health` or `/`)
- [ ] `--allow-unauthenticated` only if public-facing

```bash
# Quick validation
docker build -t test-deploy .
docker run -p 8080:8080 --env-file .env test-deploy
curl http://localhost:8080/health
```

#### Cloud Run debug runbook (when deploy fails or service 500s)

```bash
SERVICE=<service-name>; REGION=<your-region>
PROJECT=$(gcloud config get-value project)

# Status + recent revisions
gcloud run services describe $SERVICE --region=$REGION --format="value(status.conditions)"
gcloud run revisions list --service=$SERVICE --region=$REGION --limit=5

# Real-time log tail (faster than `gcloud logging read`)
gcloud beta run services logs tail $SERVICE --region=$REGION

# Errors only
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE AND severity>=ERROR" \
  --limit=20 --format="table(timestamp,textPayload)"
```

Symptom → diagnosis quick map:

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `Container failed to start` | Port mismatch (FastAPI 8000 vs CR 8080), missing env var, import error | `gcloud run services update --port=8000` or fix env |
| Python/Node traceback | Code bug | Read traceback. ADC vs service account is a frequent culprit — local works, CR breaks |
| `connection refused` to DB | Wrong DB host, missing IAM, no VPC connector | Add VPC connector or fix env |
| `Memory limit exceeded` | OOM | `gcloud run services update --memory=1Gi` |
| HTTP 403 | `--allow-unauthenticated` missing or ingress restricted | Check IAM policy + ingress annotation |
| HTTP 504 | Request > 300s default timeout | `--timeout=600` + consider `--min-instances=1` |
| Empty env var (no error) | Secret Manager secret missing IAM binding | Grant `roles/secretmanager.secretAccessor` to the runtime SA |

Rollback to previous revision when a deploy goes bad:

```bash
PREV=$(gcloud run revisions list --service=$SERVICE --region=$REGION --limit=2 --format="value(metadata.name)" | tail -1)
gcloud run services update-traffic $SERVICE --region=$REGION --to-revisions=$PREV=100
```

### Vercel

- [ ] `npm run build` succeeds locally
- [ ] `vercel.json` configured (rewrites, headers, regions)
- [ ] Environment vars set in **Vercel dashboard → Settings → Environment Variables**
- [ ] Framework preset matches project (Vite, not Next.js)
- [ ] No server-side code unless using Vercel Functions

```bash
# Quick validation
npm run build
npx vercel dev  # local Vercel preview
```

## Step 4: Deploy

```bash
# Cloudflare Pages
npx wrangler pages deploy

# Cloud Run
gcloud run deploy SERVICE_NAME \
  --source . \
  --region <your-region> \
  --allow-unauthenticated

# Vercel
npx vercel --prod
```

## Gotchas

- **CF Pages + Next.js: `output: 'standalone'` silently breaks.** The build succeeds but pages 404. Always verify `next.config.js` doesn't have it.
- **Cloud Run: ADC ≠ gcloud config ≠ service account.** Three separate auth contexts. `gcloud config set project` does NOT set Application Default Credentials. Scripts need `gcloud auth application-default login` separately. The auth that matters in production is the service account, not your local gcloud config.
- **Cloud Run: port mismatch is the #1 deploy failure.** Dockerfile `EXPOSE` and `CMD` port must match the Cloud Run `--port` flag (default 8080). FastAPI defaults to 8000 — they won't match.
- **Cloud Run: Secret Manager secrets need IAM binding.** The Cloud Run service account needs `roles/secretmanager.secretAccessor` on each secret. Missing this = empty env var, NOT an error.
- **Cloud Run: bills per request, but `--min-instances=1` runs 24/7.** Check with `gcloud run services list` after experiments.
- **Cloud Run: read-only filesystem except `/tmp`.** Writing to project directory fails silently in some frameworks.
- **Cloud Run: pick one default region and stick to it.** If a service can't be found, check the region first — `gcloud run services list` is global only with `--region` set or `--filter`.
- **Vercel: Co-Authored-By in git history blocks deploys on free tier.** Strip AI co-author trailers from commits you'll deploy on Vercel free tier.
- **Environment variables set in the dashboard don't auto-propagate to preview deployments** on both Vercel and CF Pages. You need to set them for Preview AND Production separately.
- **`wrangler pages dev` doesn't perfectly match production.** Edge cases around headers, redirects, and binding behavior differ. Always smoke-test the actual deployed URL.

## Step 5: Post-Deploy Smoke Test

### Automated checks

```bash
URL="https://your-site.example.com"

# Is the site up + response time?
curl -so /dev/null -w "HTTP %{http_code} in %{time_total}s\n" "$URL"

# HTTPS redirect works?
curl -sI "http://$(echo $URL | sed 's|https://||')" | grep -i location

# Content renders (not blank/error)?
BODY=$(curl -s "$URL")
echo "$BODY" | wc -c  # Should be > 1000 bytes
echo "$BODY" | grep -ic "error\|500\|404"  # Should be 0

# OG tags present?
echo "$BODY" | grep -i "og:title"

# API health (if applicable)
curl -s "$API_URL/health" | head -5
```

### Manual checklist
- [ ] Site responds (HTTP 200, <2s)
- [ ] HTTPS redirect works
- [ ] Content renders (not blank/error)
- [ ] OG tags present (social sharing) — verify with Twitter Card Validator + Facebook Debugger, not just visual inspection
- [ ] One critical user flow works end-to-end
- [ ] Environment vars working (auth, API calls, DB)
- [ ] Check logs: `gcloud logs read` (CR) or Vercel/CF dashboard

### First-time launch only (skip for routine deploys)
- [ ] **5-second test**: Hand the URL to one real person (not you), say nothing. If they can't tell what the product does in 5s, the hero copy is broken.
- [ ] **Mobile on actual phone**: Open the deployed URL on your phone for 5 minutes. Chrome DevTools "responsive mode" doesn't simulate touch, keyboard popups, or real network — it lies.
- [ ] **Pay yourself through the full payment flow** if money is involved.
- [ ] **First user test**: Don't coach. Hand them the URL, watch silently. If you have to explain how to start, onboarding is broken.
- [ ] **Lighthouse on the deployed URL** (not localhost). Aim for 70+ across the board. CF Pages and Vercel middleware change perf characteristics vs localhost.
- [ ] **Sentry beforeSend filter** in place if you're new to error tracking — a single retry loop can burn the 5k/mo free quota in hours.

### Post-launch (first 48 hours)
- [ ] Watch Sentry — fix crash-loops immediately, ignore feature requests
- [ ] Check analytics for actual user flow vs your assumed flow
- [ ] Get feedback from 3 real users
- [ ] Resist gold-plating: Shipped > polished-and-stuck

### Smoke test gotchas
- **DNS propagation takes up to 48h.** After DNS changes, verify with `dig +short $DOMAIN`.
- **Cloudflare cache hides broken deploys.** Append `?cache_bust=1` or purge cache in CF dashboard.
- **Cloud Run cold starts inflate latency.** First request after idle can take 5-15s. Test twice.
- **`curl` doesn't run JavaScript.** SPAs render client-side — `curl` sees empty `<div id="root">`. Use Playwright for JS-rendered content.
- **OG image URLs must be absolute.** `/og.png` won't work on Twitter/Facebook. Must be `https://example.com/og.png`.
