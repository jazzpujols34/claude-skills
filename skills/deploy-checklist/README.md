# deploy-checklist

> Pre-deploy checks that catch the failures you only notice in production — run them before every push to prod.

**What it does.** Auto-detects the target platform (Cloudflare Pages, Cloud Run, or Vercel) from the files in your project, then runs the matching pre-deploy checks: secrets in code, tracked `.env` files, `.gitignore` gaps, edge-runtime violations, Dockerfile port mismatches, Co-Authored-By trailers that break Vercel's free tier, and more. It ships four standalone bash scripts plus a checklist (build/deploy commands, a Cloud Run debug runbook, and a post-deploy smoke test) so you can automate the boring parts and follow the rest by hand.

**Install.** Copy the folder into your Claude Code skills directory:
```bash
cp -r skills/deploy-checklist ~/.claude/skills/
```
Then trigger it by describing the task in your own words — "deploy", "deploy checklist", "push to prod" — or run the scripts directly.

**Run the scripts.** From inside the installed skill folder, point each script at your project directory (defaults to `.`):
```bash
bash scripts/check-all.sh ./your-project      # universal checks — run first
bash scripts/check-cf.sh ./your-project       # Cloudflare Pages
bash scripts/check-cr.sh ./your-project       # Cloud Run
bash scripts/check-vercel.sh ./your-project   # Vercel
```
Run `check-all.sh` first, then the one platform-specific script that matches your deploy target. `check-all.sh` exits non-zero when it finds blocking issues, so it drops into CI or a pre-commit hook cleanly.

**Dependencies.** Bash, `git`, and `grep` for the universal checks. The platform scripts call the tools you'd already have for that platform: `npm` (CF Pages / Vercel builds), `docker` and `gcloud` (Cloud Run). Each script degrades gracefully — it prints `SKIP` when a tool or file isn't present rather than failing. No API keys required.
