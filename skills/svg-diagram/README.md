# svg-diagram

> Draw precise, light/dark-safe SVG diagrams inside HTML pages — without the text collisions, clipped labels, and oversized blank space that hand-written SVG usually ships with.

**What it does.** Gives an AI agent (or you) the layout math to produce clean embedded SVG diagrams — flowcharts, decision trees, layer/stack diagrams, architecture flows, tier matrices, hub-and-spoke concept heroes. The value is in `references/rules.md`: the text-fitting formulas, viewBox-height rule, and arrowhead/connector gotchas that come from real debugging, plus a binary pass/fail checklist so a diagram is either correct or it isn't.

**Install.** Copy the folder into your Claude Code skills directory:
```bash
cp -r skills/svg-diagram ~/.claude/skills/
```
Then ask for a diagram in your own words — "draw a decision tree for X", "visualize this architecture", "show the layers". The skill triggers on those.

**See it.** Open these in a browser (no server, no key needed):
- `references/resource-pills-example.html` — the **clean + resource-pills** style (Track A, the default), with a live light/dark toggle.
- `references/concept-hero-example.html` — the **hand-drawn concept hero** style (Track B), dark-first.

**Dependencies.** None for the default clean style — it's pure inline SVG with CSS variables for theming. The optional hand-drawn "concept hero" style pulls [rough.js](https://roughjs.com/) from a CDN; skip it and the clean style covers everything.

**Read first (for agents).** `references/rules.md` before writing any SVG; `references/page-structure.md` if you're building a full multi-section HTML page; `references/concept-hero-style.md` for the two-style system and the resource-pill vocabulary.
