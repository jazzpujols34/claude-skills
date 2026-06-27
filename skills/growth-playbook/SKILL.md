---
name: growth-playbook
description: Post-launch marketing and growth. Trigger on "get customers", "how to sell", "landing page copy", "conversion", "CRO", "growth", "marketing", "email sequence", "distribution", "get users", or when a shipped product has zero customers. This is the skill for AFTER you ship.
---

# Growth Playbook

> Adapted from [marketingskills](https://github.com/coreyhaines31/marketingskills) by Corey Haines (see README Credits).

> You shipped it. Now sell it. This skill covers everything between "it's live" and "first paying customer."

## Detection — When to Activate

- Product is deployed but has no/few users
- User asks about marketing, distribution, or growth
- User wants landing page copy, email sequences, or conversion optimization
- The priority stack says "get first customer" (e.g. a product just shipped with zero customers)

## Phase 0: Product Marketing Context (fill this FIRST)

Every growth activity starts here. Fill this template once per product — all other phases reference it.

```markdown
## Product Marketing Context: [Product Name]

### Product
- **One-liner:** [what it does in ≤10 words]
- **Category:** [what shelf does it sit on?]
- **Core value prop:** [one sentence — outcome, not feature]

### Customer
- **Primary persona:** [role + situation + goal]
- **Pain points (top 3):**
  1. [pain] — [how they currently cope]
  2. [pain] — [how they currently cope]
  3. [pain] — [how they currently cope]
- **Customer language:** [exact phrases from reviews, support tickets, forums — NOT your marketing copy]
- **Where they hang out:** [specific communities, platforms, groups]

### Competitive Landscape
- **Direct alternatives:** [what they'd use instead of you]
- **Status quo:** [what they do if they use nothing]
- **Switching cost:** [what makes leaving the current solution hard?]

### Differentiation
- **Why you, not them:** [one thing — not five]
- **Proof:** [demo, testimonial, number, before/after]

### Objections (top 3)
1. "[objection]" → [counter with evidence]
2. "[objection]" → [counter with evidence]
3. "[objection]" → [counter with evidence]

### Brand Voice
- **Tone:** [e.g., warm but direct, technical but accessible]
- **Words we use:** [list]
- **Words we never use:** [list]
```

**This template is the linchpin.** Every subsequent phase pulls from it. Update it when you learn new things from users.

---

## Pre-Check: Ship or Sell?

Before marketing, confirm the product is actually ready:

**Ship now if ANY true:**
- Core value prop works, first 3 users can complete the main flow
- You're polishing instead of building, or "almost done" for >1 week

**Keep building if ALL true:**
- Critical bug blocks the main flow
- Payment doesn't work (if monetized)
- Legal/security risk exists

**Kill if ANY true:**
- Lost interest for >2 weeks, market feedback consistently negative, better opportunity appeared

**Anti-patterns:** "Just one more feature" = fear of judgment → ship. "Not perfect yet" = perfectionism → ship. "Need to refactor first" = procrastination → ship.

---

## Phase 1: Positioning (do this first)

Before writing any copy, answer these 5 questions:

### 1. Who is the customer? (One sentence)
Not "everyone." The most specific person who will pay.
```
Bad:  "People who want memorial videos"
Good: "Families who lost a parent and want a 3-minute tribute video for the funeral"
```

### 2. What's the alternative? (What they do today without you)
```
- Hire a videographer (expensive, 1-2 weeks)
- Use a free slideshow app (ugly, no music sync)
- Skip it entirely
```

### 3. What makes you different? (One thing, not five)
Pick the single biggest differentiator. Not features — outcome.
```
"AI generates a polished memorial video in 10 minutes for the price of a coffee run"
```

### 4. What's the proof?
Social proof, demo, numbers, before/after. No proof = no trust.

### 5. What's the ask?
One CTA per page. Not "sign up AND follow us AND share." One thing.

## Phase 2: Landing Page Audit

Run this checklist against the existing landing page:

| Element | Check | Fix |
|---------|-------|-----|
| **Hero headline** | States the outcome, not the feature? | "Create a memorial video in 10 minutes" not "AI Video Generator" |
| **Subhead** | Answers "for who" and "compared to what"? | |
| **CTA above fold** | Visible without scrolling? One clear action? | |
| **Social proof** | Testimonial, demo video, or number visible? | |
| **Price anchor** | Compared to the alternative's cost? | "$9 vs $300+ for a videographer" |
| **Objection handling** | Top 3 objections addressed on page? | |
| **Mobile** | Loads in <3s? CTA thumb-reachable? | |
| **Speed** | No layout shift? Images optimized? | |

### Hero Formula

```
[Outcome] + [timeframe] + [without the pain]

Examples:
- "Memorial videos that honor a life — ready in 10 minutes"
- "Track your investments without spreadsheet hell"
- "Ship your side project this weekend, not next quarter"
```

**Anti-patterns (never write these):**
- "Welcome to [product name]" — nobody cares about your name
- "The ultimate/revolutionary/next-gen..." — significance inflation
- "Powered by AI" as the hero — the customer wants the outcome, not the tech

## Phase 3: Distribution Channels

Pick 2 max. Do them well before adding a third.

### For a local-services / life-event B2C product (e.g. memorial videos):
1. **Niche Facebook groups** — communities around the life event (e.g. funeral/memorial groups). Answer questions, share value, soft-link.
2. **Partnerships at the point of need** — partner with the businesses that already have the customer at the exact moment of need (e.g. funeral homes). Offer white-label or a referral fee.
3. **Local messaging groups** — wherever the target families coordinate (e.g. LINE/WhatsApp/community chats).

### For SaaS/dev tools:
1. **X/Twitter** — build-in-public threads (use the x-thread-compiler skill if available)
2. **Product Hunt** — one-time spike, good for backlinks
3. **SEO** — long-tail content (use the seo-audit skill if available)

### For content/portfolio:
1. **Personal site + SEO** — evergreen
2. **Medium/Dev.to** — syndicate, link back
3. **X threads** — atomic content from articles

## Phase 4: Conversion Optimization (CRO)

### Measure first
Before optimizing, set up tracking:
```
- GA4 events: page_view, cta_click, signup, purchase
- Funnel: landing → signup → first_use → payment
- Where do people DROP? Fix that step first.
```

### Quick wins (ordered by impact)
1. **Reduce friction** — Remove unnecessary form fields. Email-only signup beats name+email+password.
2. **Add urgency** — Limited-time pricing, countdown, scarcity (only if real).
3. **Social proof** — Even 1 testimonial beats 0. Ask your first user.
4. **Speed** — Every 100ms delay = 1% conversion drop. Lighthouse audit.
5. **Trust signals** — Payment badges, privacy note, refund policy.

### A/B Testing Rules
- Test ONE thing at a time
- Need 100+ visitors per variant for significance
- Run for 2+ weeks minimum
- If traffic is low (<500/month), don't A/B test — just ship the better version

## Phase 5: Email / Messaging

### Welcome Sequence (3 emails)
```
Email 1 (immediate): Deliver what they signed up for. No fluff.
  - Subject: "Here's your [thing]"
  - CTA: Use the product

Email 2 (day 2): Show the #1 feature they haven't tried.
  - Subject: "Most people miss this"
  - CTA: Try the feature

Email 3 (day 5): Social proof + ask.
  - Subject: "[Name] used [product] for [result]"
  - CTA: Upgrade / buy / share
```

### Rules
- Plain text > HTML templates (feels personal)
- One CTA per email
- Subject line < 40 characters
- Send from a person's name, not the product name
- Unsubscribe link always visible

## Phase 6: Content-Led Growth

### The Atomic Content Method
1. Write ONE long-form piece (article, guide, case study)
2. Extract from it:
   - 3-5 X thread tweets (use the `x-thread-compiler` skill if available)
   - 1 LinkedIn post
   - 2-3 short-form quotes for IG stories
   - 1 email to your list
3. Each piece links back to the original

### Content that converts
| Type | When to use | Conversion |
|------|-------------|------------|
| Tutorial / How-to | SEO, evergreen traffic | Medium |
| Case study | Social proof, closing sales | High |
| Comparison | "X vs Y" SEO keywords | High |
| Behind-the-scenes | Build-in-public audience | Low but builds trust |

## Output Template

When this skill is triggered, produce:

```markdown
## Growth Audit: [Product Name]

### Positioning
- **Customer:** [one sentence]
- **Alternative:** [what they do without you]
- **Differentiator:** [one thing]
- **Proof:** [what you have / what you need]

### Landing Page Score: X/8
[Checklist results]

### Top 3 Actions (ordered by impact)
1. [action] — expected impact, effort level
2. [action] — expected impact, effort level
3. [action] — expected impact, effort level

### Distribution Plan
- Channel 1: [channel] — [specific tactic] — [timeline]
- Channel 2: [channel] — [specific tactic] — [timeline]
```

## Phase 7: Churn Prevention (after you have users)

### Voluntary Churn — Cancel Flow
```
Trigger (cancel click) → Exit Survey (5-8 reasons) → Dynamic Save Offer → Confirmation → Post-Cancel
```

**Save offer mapping:**
| Reason | Offer |
|--------|-------|
| Too expensive | 20-30% discount for 3 months |
| Not using it enough | Pause subscription (1-3 months) |
| Missing feature | Roadmap preview + timeline |
| Switching to competitor | Comparison sheet + discount |
| Technical issues | Escalate to support immediately |

**Benchmarks:** Save rate 25-35%, pause reactivation 60-80%.

### Involuntary Churn — Dunning
- Pre-dunning: card expiry alerts at 30/15/7 days
- Smart retry: soft decline = retry in 24h, hard decline = notify user immediately
- Dunning emails: Day 0, 3, 7, 10
- Grace period before hard cancel
- Always provide a reactivation path

## Gotchas

- **"Build it and they will come" is the #1 killer of indie products.** If there's no distribution plan, the product is dead on arrival regardless of quality.
- **Don't optimize conversion before you have traffic.** 2% of 0 is still 0. Get eyeballs first.
- **Regional channels matter — pick the channel your market actually checks.** In many markets a messaging app (LINE, WhatsApp) beats email for B2C, because consumers don't read marketing email. Check where your customers actually are before defaulting to email.
- **Old-but-massive channels still work — don't skip them because they feel dated.** In some markets niche Facebook groups carry enormous reach. Match the channel to where the audience already gathers, not to what feels modern.
- **Price anchoring works best when the alternative is expensive and familiar.** "$9 vs a $300 videographer" is powerful. "$9 vs a free slideshow app" is not.
- **First customer > first 100 customers.** Manually reach out to 10 people who fit your customer profile. DM them. Offer it free in exchange for feedback. One real user teaches you more than any marketing framework.
