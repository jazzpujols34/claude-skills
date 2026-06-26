# seo-audit

> Full-site SEO analysis with actionable fixes — from meta tags and schema markup to content strategy and AI-search (GEO). Reach for it before a launch, when organic traffic stalls, or when publishing.

**What it does.** Walks an agent through a structured SEO audit of any web project in five phases: technical SEO (crawlability, on-page tags, structured data), content SEO (keyword research, content audit, gap analysis), GEO / AI-search optimization (citability, AI-crawler access, `llms.txt`), link building, and site-type recommendations. It ships ready-to-paste curl checks, fill-in checklists, JSON-LD schema templates, and an output report template, plus a Gotchas section of hard-won edge cases.

**Install.** Copy the folder into your Claude Code skills directory:
```bash
cp -r skills/seo-audit ~/.claude/skills/
```
Then trigger it by describing the task in your own words — "audit my site's SEO", "add schema markup", "why isn't my site ranking", "optimize for AI search". The skill listens for those phrases (see the `description` in [`SKILL.md`](SKILL.md)).

**Dependencies.** None. The checks use `curl` (and optionally `npx lighthouse`); no API key required.
