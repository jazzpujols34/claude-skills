# growth-playbook

> Everything between "it's live" and "first paying customer" — positioning, landing-page copy, distribution, CRO, email, and churn prevention.

**What it does.** This is the AFTER-you-ship skill: once a product is deployed, it turns "I built it, now what?" into an ordered playbook. It walks through one product-marketing context doc, then positioning, a landing-page audit, channel selection, conversion optimization, email sequences, content-led growth, and churn prevention — each phase with copy formulas, checklists, and anti-patterns instead of vague advice.

**Install.** Copy the folder into your Claude Code skills directory:
```bash
cp -r skills/growth-playbook ~/.claude/skills/
```

**How to trigger it.** Describe the growth task in your own words — "get customers", "how do I sell this", "write landing page copy", "improve conversion / CRO", "growth", "marketing", "email sequence", "distribution", "get users" — or ask for help when a shipped product still has zero customers. The skill listens for those phrases (see the `description` in [`SKILL.md`](SKILL.md)).

**Dependencies.** None. It's a pure prompt/playbook — no scripts, no API keys. It references two optional sibling skills by name (x-thread-compiler, seo-audit) but works fully without them.
