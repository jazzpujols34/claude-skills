---
name: seo-audit
description: SEO audit and optimization for web projects. Trigger on "SEO", "search ranking", "audit my site", "schema markup", "meta tags", "sitemap", "search console", "organic traffic", or when optimizing a site for search engines. Works for any web project.
---

# SEO Audit

> Full-site SEO analysis with actionable fixes. From meta tags to structured data to content strategy and AI-search (GEO).

## When to Use

- Before launching a new site or page
- When organic traffic matters (personal site, product landing pages)
- When publishing articles (any blog or publication platform)
- When the user says "SEO", "search ranking", "why isn't my site showing up"

## Phase 1: Technical SEO Audit

### 1.1 Crawlability Checklist

Run these checks against the target URL:

```bash
# Check if robots.txt exists and what it allows
curl -s https://[domain]/robots.txt

# Check sitemap
curl -s https://[domain]/sitemap.xml | head -50

# Check response headers
curl -sI https://[domain]/

# Check page load speed (if lighthouse available)
# npx lighthouse https://[domain] --only-categories=performance,seo --output=json
```

| Check | Status | Fix |
|-------|--------|-----|
| `robots.txt` exists and doesn't block important pages | | |
| `sitemap.xml` exists and is up-to-date | | |
| All pages return 200 (no 404s, no redirect chains) | | |
| HTTPS everywhere (no mixed content) | | |
| Mobile responsive (viewport meta tag) | | |
| Page load < 3s (LCP) | | |
| No orphan pages (every page linked from at least one other page) | | |

### 1.2 On-Page SEO Checklist

For each important page, check:

| Element | Rule | Current | Fix |
|---------|------|---------|-----|
| `<title>` | 50-60 chars, keyword near front | | |
| `<meta description>` | 150-160 chars, includes CTA | | |
| `<h1>` | Exactly one per page, contains primary keyword | | |
| `<h2>`-`<h6>` | Logical hierarchy, no skipped levels | | |
| Images | All have `alt` text, compressed, proper format (WebP) | | |
| Internal links | Key pages linked from homepage/nav | | |
| URL structure | Short, readable, hyphens not underscores | | |
| Canonical tag | `<link rel="canonical">` on every page | | |
| Open Graph | `og:title`, `og:description`, `og:image` set | | |
| Twitter Card | `twitter:card`, `twitter:title`, `twitter:image` set | | |

### 1.3 Structured Data (Schema Markup)

Check for and recommend JSON-LD structured data:

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebSite",  // or Person, Article, Product, etc.
  "name": "...",
  "url": "...",
  ...
}
</script>
```

| Page Type | Recommended Schema | Priority |
|-----------|-------------------|----------|
| Homepage (personal site) | `Person` + `WebSite` | High |
| Blog post / Article | `Article` + `BreadcrumbList` | High |
| Product / pricing page | `Product` + `Offer` | High |
| Portfolio / Gallery | `CreativeWork` or `ImageGallery` | Medium |
| FAQ page | `FAQPage` | Medium |

Validate at: https://search.google.com/test/rich-results

## Phase 2: Content SEO

### 2.1 Keyword Research (Manual Method)

When you don't have paid SEO tools, use these free approaches:

1. **Google autocomplete** — Type the topic, note suggestions
2. **"People also ask"** — Search the topic, expand all PAA boxes
3. **Related searches** — Bottom of Google results page
4. **Google Trends** — Compare keyword variants (especially across languages/locales)
5. **Answer the Public** (answerthepublic.com) — Question-based keywords

### 2.2 Content Audit

For existing content, check:

| Page/Post | Primary Keyword | Word Count | Last Updated | Inbound Links | Action |
|-----------|----------------|------------|--------------|---------------|--------|
| ... | ... | ... | ... | ... | Keep/Update/Merge/Delete |

Rules:
- **< 300 words** → too thin. Expand or merge with another page
- **> 12 months since update** → refresh or add "Updated YYYY-MM" note
- **No inbound links** → orphan content. Link from other pages or delete
- **Multiple pages targeting same keyword** → merge (keyword cannibalization)

### 2.3 Content Gap Analysis

Compare what you have vs what your audience searches for:

```markdown
## Keywords We Rank For
(Check Google Search Console → Performance → Queries)

## Keywords We Should Target
1. [keyword] — monthly search volume estimate, difficulty
2. [keyword] — ...

## Content to Create
1. [topic] targeting [keyword] — format: [article/guide/comparison]
2. ...
```

## Phase 3: GEO — AI Search Optimization

Google AI Overviews, ChatGPT, Perplexity are now sending traffic. Optimize for them too.

### 3.1 Citability Score

AI models cite content that is:
- **Self-contained passages** — 134-167 words per key section (optimal for AI citation)
- **Factual and specific** — numbers, dates, comparisons (not vague claims)
- **Structured** — clear headings, lists, tables (easy to extract)
- **Authoritative** — author bio, credentials, sources cited

### 3.2 AI Crawler Access

Check if AI crawlers can access your site:

```bash
# Check robots.txt for AI bot rules
curl -s https://[domain]/robots.txt | grep -i "GPTBot\|ClaudeBot\|PerplexityBot\|ChatGPT\|Google-Extended"
```

| Crawler | User-Agent | Recommendation |
|---------|-----------|----------------|
| Google AI Overview | Google-Extended | Allow (you want AIO citations) |
| ChatGPT | GPTBot | Allow (free traffic) |
| Claude | ClaudeBot | Allow |
| Perplexity | PerplexityBot | Allow |

If robots.txt blocks these, you're invisible to AI search.

### 3.3 llms.txt

Create a `/llms.txt` file at your site root — a machine-readable site summary for AI crawlers:

```
# [Site Name]

> [One-line description]

## Docs
- [Page title](URL): [one-line description]
- [Page title](URL): [one-line description]

## API
- [Endpoint](URL): [description]
```

### 3.4 Content Optimization for AI Citations

| Element | Traditional SEO | AI SEO (GEO) |
|---------|----------------|---------------|
| Headlines | Keyword-first | Question-first ("How to...", "What is...") |
| Content length | 1500-2500 words | 134-167 word self-contained passages within longer content |
| Structure | H2/H3 hierarchy | Definitive statements early in each section |
| Proof | Backlinks | Named sources, specific numbers, comparison tables |
| Freshness | Annual updates | Dated facts, "as of [date]" markers |

## Phase 4: Link Building (Solo Builder Edition)

If you're one person, focus on these high-ROI link strategies:

1. **Personal profiles** — GitHub, LinkedIn, dev.to, and other publishing platforms. All link back to your site.
2. **Guest posts** — Write for communities you're already in (company blogs, developer communities)
3. **Build-in-public content** — "How I built X" posts naturally attract links
4. **Open source** — Repos link to your site in README/docs
5. **Directories** — Product Hunt, Indie Hackers, relevant niche directories

**Don't waste time on:**
- Link exchanges / reciprocal linking
- Buying links
- Spamming forums
- PBNs (private blog networks)

## Phase 5: Site-Type Recommendations

### Personal site / portfolio
- Schema: `Person` with `sameAs` linking to GitHub, LinkedIn
- Target keywords: your name, your specialty + location, signature topics you publish about
- Content: guides, project case studies, speaking/presentation links

### Product / SaaS landing page
- Schema: `Product` + `Offer` with pricing
- Target keywords: the job-to-be-done, "[category] generator/tool", problem-phrased queries
- Content: how-to guides, sample output, pricing comparison vs the manual alternative

### Web app / tool
- Schema: `WebApplication` + `SoftwareApplication`
- Target keywords: "[task] online", "[task] tool", the workflow it replaces
- Content: featured use cases, how it works, accuracy/quality comparisons

## Output Template

```markdown
# SEO Audit: [domain]

**Date:** YYYY-MM-DD
**Overall Score:** X/10

## Critical Issues (fix immediately)
1. ...
2. ...

## Warnings (fix soon)
1. ...
2. ...

## Opportunities (growth potential)
1. ...
2. ...

## Technical Checklist: X/Y passed
[Table from Phase 1]

## Content Recommendations
[From Phase 2]

## Next Steps (prioritized)
1. [action] — impact: high/med/low, effort: high/med/low
2. ...
```

## Gotchas

- **Client-side rendered SPAs need special SEO handling.** Pages rendered only in the browser are invisible to crawlers that don't execute JS. Use SSR/SSG (e.g. Next.js) or prerender routes. Check with `curl` — if the returned HTML is empty, search engines see nothing.
- **Multi-locale SEO is a different game.** Results on a country-specific Google domain (e.g. google.com.tw) differ from google.com. Test both. Traditional Chinese keywords have different search volumes than Simplified — same lesson applies to any locale split.
- **Don't obsess over meta descriptions.** Google rewrites them ~70% of the time anyway. Make them good but don't spend hours perfecting them.
- **Schema markup doesn't directly improve rankings** but it gets you rich snippets (stars, prices, FAQ dropdowns) which improve click-through rate, which DOES improve rankings.
- **New sites take 3-6 months to rank.** Don't check daily. Set a monthly review cadence.
- **Google Search Console is free and essential.** If it's not set up, that's the first fix. Everything else is guessing without data.
