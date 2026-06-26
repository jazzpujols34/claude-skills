# Two diagram styles

Pick by label language + diagram role. Working examples in this folder:
`concept-hero-example.html` (the hand-drawn hero) and `resource-pills-example.html`
(clean + pills, with a light/dark toggle).

---

## Track A — Clean + resource pills (DEFAULT, use for almost everything)

The everyday workhorse, especially for **data-dense diagrams** (spec tables,
cross-sections, pyramids, flows) and **CJK labels**. Clean geometric strokes via
CSS-var tokens (the `rules.md` style) **plus** the resource-pill vocabulary below.
Works in light AND dark, CJK-safe, single-file, zero dependencies. Make this your
default.

## Track B — Hand-drawn concept hero (SPECIAL, ≤1 per page)

A marker-on-dark-glass "concept board" look — a title written as a short equation, a
hub-and-spoke or loop, satellites. Use **only** for a single high-level *conceptual*
diagram, **English / short labels**, **dark-first**. NOT for data-dense diagrams. See
"Cost" below.

---

## Resource-pill vocabulary (BOTH tracks — shared tag colours)

Small chunky rounded pills tagging a box with the resources it uses. Solid fill +
dark/white text, `rx:7`, ~`52×21`. Assign **one accent colour per resource class** and
keep it constant across light/dark (pills don't theme-flip). A hardware example set:

| Class | Example tags | Hex |
|-------|--------------|-----|
| Compute | GPU / accelerator / "tokens" | `#76B900` (or `--green`) |
| Fast memory | HBM / on-package RAM | `#76B900` / `--green` |
| Main memory | DRAM | `#0D9488` (`--teal`) |
| Storage | SSD / NAND | `#DC2626` (`--coral`) |
| Host | CPU | `#2F7DEB` (`--blue`/`--indigo`) |
| Data movement | DPU / NIC | `#E0900F` (`--amber`) |

Swap the labels for your own domain — the point is *one stable colour per class*.
Always include a small legend row (swatch + label) near the diagram. In Track A use
the page's `--*-solid` tokens so dark mode stays safe; in Track B a punchy green like
`#76B900` reads best on the dark canvas.

---

## Track B recipe (the details that make it look "designed")

Four things separate a premium hand-drawn hero from a crude one — all four matter:

1. **Hand-lettered font** — e.g. `Shantell Sans` (Google Fonts), all-caps-ish labels,
   `letter-spacing ~.04em`. Title as a short equation: `"<THING> = <A> + <B>"`. Latin
   only — there is no good handwritten CJK font, so this track is English-label-only.
2. **Rich interior, not an empty box** — the hub holds an inner routed loop (e.g.
   ATTEND → GENERATE → APPEND, each with a pill) + a clean **loop-back bracket** in the
   LEFT margin (a dot leaving the bottom row, a rounded `[`-bracket up the margin,
   arrowhead returning into the top row, "loop" label). Keep the bracket clear of the
   pills and the box edge.
3. **Soft glow + vignette** — wrap strokes in a `feGaussianBlur` glow filter; fill the
   canvas with a `radialGradient` vignette (`#13131b`→`#07070b`). This is the "marker on
   dark glass" depth.
4. **LEVEL orthogonal connectors (never diagonal)** — the thing that most often looks
   wrong. Position the satellites so their vertical centres equal the hub's two entry
   heights (`HY_HI`, `HY_LO` inside the hub's y-span), then draw **straight horizontal**
   arrows satellite↔hub at that exact y; bottom node = straight vertical. Use rough.js
   with **low** wobble for connectors (`roughness:0.6, bowing:0.25`) so they read as
   confident hand lines, not scribbles. Boxes can be wobblier (`roughness:0.9, bowing:0.9`).

Built with **rough.js** (`https://unpkg.com/roughjs@4.6.6/bundled/rough.js`). Arrowheads:
draw explicit filled triangles via the angle (see `arrowHead(x,y,ang,c)` in the example)
— do NOT use SVG markers with `orient="auto"` (see the marker gotcha in SKILL.md).

### Cost / when NOT to use Track B
- Adds a **rough.js runtime dependency** → breaks the single-file-static rule, and a
  static linter can't check the JS-generated paths. Only worth it for the one hero.
- **CJK labels** fall back to a clean font → the hand-feel half-evaporates. So Track B is
  English-concept-only; any CJK-labelled diagram → Track A.
- Data-dense diagrams (matrices, cross-sections) need precision → Track A.

See `concept-hero-example.html` for the full, working, arrows-fixed implementation.
