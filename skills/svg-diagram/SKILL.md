---
name: svg-diagram
description: Draw SVG diagrams inside HTML pages — flowcharts, decision trees, layer diagrams, architecture flows, tier matrices. Use this skill whenever the user asks for a diagram, visual flow, architecture drawing, or any SVG-based visual inside an HTML document. Also use when building single-file HTML reference pages that need section diagrams. Triggers on phrases like "draw a diagram", "add a flow chart", "visualize the architecture", "decision tree", "show the layers", or when building HTML pages with embedded SVG visuals. Do NOT use for standalone image generation or React/canvas-based visualizations.
---

# SVG Diagram Skill

Creates precise, well-laid-out SVG diagrams embedded in HTML pages. These diagrams use CSS variables for light/dark mode support and follow strict text-fitting rules to prevent overlap and clipping.

Read `references/rules.md` before writing any SVG code. It contains the layout math, text-fitting formulas, and anti-patterns learned from production debugging.

If building a full HTML reference page with multiple sections, also read `references/page-structure.md` for the single-file page layout spec.

**Two diagram styles — read `references/concept-hero-style.md`.**
(A) **Clean + resource pills** = the DEFAULT for almost everything, especially data-dense
diagrams and CJK labels;
(B) **Hand-drawn concept hero** (rough.js + a handwritten Latin font + inner loop + glow +
vignette) = at most ONE English/concept diagram per page, dark-first. A shared
**resource-pill vocabulary** (one accent colour per resource type — e.g. compute green ·
memory teal · storage coral · controller blue) applies to BOTH. Working examples:
`references/concept-hero-example.html`, `references/resource-pills-example.html`.

**Porting a diagram into a React/JSX app?** Keep the marker IDs unique per instance
(all diagrams may share one DOM), convert `class`→`className`, camelCase inline styles,
and keep `font-family` inline on each `<svg>` so it doesn't inherit from the host app.

## When to Use

- Decision trees ("should I use X or Y?")
- Layer/stack diagrams (bottom-to-top, like OSI layers or detection stacks)
- Flow diagrams (left-to-right process with arrows)
- Tier selection matrices (input → tier → config → use case)
- Architecture diagrams (components with arrows showing data flow)
- Any SVG visual embedded inside an HTML `<div>`

## Quick Start

Every SVG diagram follows this skeleton:

```html
<div class="card card-diagram">
  <h3>Diagram title</h3>
  <svg width="100%" viewBox="0 0 920 H" xmlns="http://www.w3.org/2000/svg"
       style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif">
    <defs>
      <marker id="aX" viewBox="0 0 10 10" refX="8" refY="5"
              markerWidth="6" markerHeight="6" orient="auto-start-reverse">
        <path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke"
              stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
      </marker>
    </defs>
    <!-- diagram content -->
  </svg>
</div>
```

Where:
- ViewBox width is always **920**
- **H** = calculated height (see rules)
- Marker **id** must be unique per diagram (`a1`, `a2`, `a3`...)
- Container has `overflow-x: auto` for mobile scroll

## Diagram Types

### Decision Tree
Horizontal left-to-right flow with branching Yes/No paths.
- Decision nodes: dashed border (`stroke-dasharray="4 3"`)
- Outcome nodes: solid border
- Use green for preferred/cheap paths, amber for expensive/last-resort
- Add cost/speed labels below outcome nodes

### Layer Diagram
Stacked horizontal bars, bottom-to-top.
- Each bar: 52px tall minimum (two-line content)
- Line 1: bold label (font-size 13, font-weight 600)
- Line 2: description (font-size 11, opacity 0.75)
- Bars should be 740px wide max, leaving room for side labels
- Side labels in a separate column to the right

### Flow Diagram
Left-to-right process steps connected by arrows.
- Consistent box sizes per row
- Arrows use `marker-end="url(#aX)"`
- Use `class="arr"` stroke style or explicit stroke color

### Tier Matrix
Columns mapping inputs to outputs.
- Aligned rows with consistent heights
- Arrows between columns
- Each column has a header label

## Quality Checklist (Binary — Pass/Fail)

### Technical correctness
1. **Text overlap**: any two `<text>` within 5px on y-axis — check horizontal bounds don't intersect
2. **Text clipping**: every text element's computed right edge ≤ 920, left edge ≥ 0
3. **Text in rects**: (chars × font-size × 0.58) + 24px ≤ rect width
4. **viewBox height**: max(all element bottoms) + 20px, not a round guess
5. **No side-by-side label+description**: always two-line layout
6. **All colors use CSS variables**: no hardcoded hex
7. **Marker IDs unique**: no two diagrams on the page share a marker `id`

### Information design
8. **5-second test**: Can a reader understand the diagram's main point within 5 seconds of looking at it?
9. **Labels self-sufficient**: Can you understand every node/box without reading surrounding prose?
10. **Visual hierarchy**: Is the most important path/element visually distinct (color, weight, or size)?

## Gotchas

- **SVG marker IDs are document-global.** If two diagrams both define `id="arrow"`, the second silently overrides the first. Use unique IDs per diagram (`a1`, `a2`, ...). In a single-page app, every diagram may be in the DOM at once, so this matters more.
- **`font-family` must be inline on the `<svg>` element.** CSS inheritance from the parent page doesn't reliably reach into SVG. Always set it explicitly.
- **`context-stroke` on markers** only works when the `<line>` has an explicit `stroke`. If using CSS classes for stroke, the marker arrowhead may not inherit the color.
- **text-anchor="middle" shifts both edges.** A centered text at x=460 with 300px width spans 310–610, not 460–760. Always calculate both edges.
- **Dark mode: all fills/strokes must use CSS variables.** Hardcoded hex values won't adapt. Test by toggling the system theme (for `prefers-color-scheme`) or the `data-theme` attribute (if your app themes that way).
- **viewBox height rounding wastes space.** Setting height to 400 when content ends at 283 creates a 117px blank bar at the bottom of the diagram card. Calculate from actual content.
- **Arrowheads: define the marker pointing RIGHT (+x), or draw an explicit triangle by angle — NEVER define a down-pointing marker with `orient="auto"`.** A marker whose path apex points down (`M0 0 L9 0 L4.5 9z`) combined with `orient="auto"` double-rotates: on a downward line it ends sideways, on a rightward line it points down — both read as a broken arrowhead (a repeat offender across builds). Either use one canonical right-pointing marker (`refX≈7 refY≈4.5`, path `M0,0 L9,4.5 L0,9 z`, `orient="auto"`) — it then rotates correctly for ANY direction including down — or, for hand-drawn/rough diagrams, draw a filled triangle from the line angle (`arrowHead(x,y,ang,color)` in `references/concept-hero-example.html`).
- **Connectors must be LEVEL, never skewed.** Diagonal hub↔node lines look amateur. Position satellites so their centres equal the hub's entry heights, then draw straight horizontal/vertical arrows. For rough.js connectors use low wobble (`roughness:0.6, bowing:0.25`); save the wobble for the boxes.
- **A hub box must have a rich interior, not be empty.** For concept heroes, put an inner routed loop with stage labels + pills + a clean loop-back bracket (clear of the pills and the box edge) — see `concept-hero-style.md`. An empty labelled box reads as unfinished.
