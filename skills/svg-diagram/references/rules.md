# SVG Diagram Rules Reference

These rules were learned from 5 rounds of production debugging. Every rule exists because it caught a real bug.

## ViewBox Setup

```
<svg width="100%" viewBox="0 0 920 H">
```

- Width is ALWAYS 920. Never change it.
- H = tight calculated height (see below)
- The diagram card CSS sets `min-width: 700px` on the SVG so it scrolls horizontally on mobile instead of shrinking to unreadable text

### Calculating H (viewBox height)

1. Find all rects: collect `y + height` for each
2. Find all text: collect `y + 4` for each (4px for descender)
3. H = max(all values) + 20
4. Never round to a nice number. 283 is correct if the math says 283.

**Why this matters:** Excess height creates a visible blank bar at the bottom of the diagram card. Users will see it and ask what's wrong.

## Text Layout — The #1 Failure Mode

### Two-Line Rule (MANDATORY)

Never place a bold label and a description side-by-side on the same y-line.

**Wrong:**
```svg
<text x="50" y="40" font-weight="600">Network layer</text>
<text x="250" y="40">IP reputation • TLS fingerprint • TCP stack</text>
```
These WILL overlap when the label is long or the description is long.

**Correct:**
```svg
<text x="50" y="40" font-size="13" font-weight="600">Network layer</text>
<text x="50" y="58" font-size="11" opacity="0.75">IP reputation • TLS fingerprint • TCP stack</text>
```
Label on line 1, description on line 2. The containing rect must be 52px+ tall.

### Text Width Estimation

Formula: `width_px = character_count × font_size × 0.58`

Examples:
- "Exponential backoff + jitter" (28 chars, font-size 12) = 28 × 12 × 0.58 = **195px**
- "HTTP/2 SETTINGS frame" (21 chars, font-size 11) = 21 × 11 × 0.58 = **134px**
- "Mouse entropy • Scroll patterns • Typing cadence" (49 chars, font-size 11) = 49 × 11 × 0.58 = **313px**

Use this formula before placing any text. Don't eyeball it.

### text-anchor Math

The `text-anchor` attribute changes where the text extends from x:

| text-anchor | Left edge | Right edge |
|---|---|---|
| `start` (default) | x | x + width |
| `middle` | x - width/2 | x + width/2 |
| `end` | x - width | x |

Check BOTH edges against viewBox boundaries (0 and 920).

### 40px Gap Rule

Before placing any element adjacent to text, calculate:
```
text_right_edge + 40 < next_element_x
```

If this is false, the text and the element WILL visually collide, even if they don't technically overlap at the pixel level.

### Text Inside Rects

For text centered in a rect (`text-anchor="middle"`, x at rect center):
```
required_rect_width = text_width + 24   (12px padding each side)
```

If `required_rect_width > actual_rect_width`, either widen the rect or shorten the text. Text WILL overflow the rect visually.

## Color Rules

### All Colors Must Use CSS Variables

```svg
<!-- CORRECT -->
<rect fill="var(--accent-blue-bg)" stroke="var(--accent-blue)"/>
<text fill="var(--accent-blue-text)">Label</text>

<!-- WRONG — won't adapt to dark mode -->
<rect fill="#E6F1FB" stroke="#185FA5"/>
<text fill="#0C447C">Label</text>
```

### Color Semantics

Use color to encode meaning, not sequence:
- **Green**: preferred, fast, cheap, success
- **Amber**: caution, last resort, expensive
- **Coral/Red**: blocked, error, burned
- **Blue**: info, neutral data
- **Purple**: decision points, primary categories
- **Teal**: secondary categories, alternative paths
- **Gray**: neutral, structural, start/end

### Decision Node Styling

```svg
<!-- Decision (dashed border) -->
<rect rx="8" fill="var(--accent-purple-bg)" stroke="var(--accent-purple)"
      stroke-width="1" stroke-dasharray="4 3"/>

<!-- Outcome (solid border) -->
<rect rx="8" fill="var(--accent-green-bg)" stroke="var(--accent-green)"
      stroke-width="0.5"/>
```

## Arrow Markers

Each diagram needs a unique marker ID in its `<defs>`:

```svg
<defs>
  <marker id="a1" viewBox="0 0 10 10" refX="8" refY="5"
          markerWidth="6" markerHeight="6" orient="auto-start-reverse">
    <path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke"
          stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  </marker>
</defs>
```

Use `marker-end="url(#a1)"` on lines. The `context-stroke` makes the arrowhead match the line color automatically.

Marker IDs: `a1`, `a2`, `a3`... one per diagram. In practice, inline SVGs in the same HTML document share marker IDs globally, so later diagrams can reference earlier markers. But define one per diagram for clarity.

## Connecting Lines

```svg
<!-- Simple arrow -->
<line x1="200" y1="60" x2="260" y2="60"
      stroke="var(--text-tertiary)" stroke-width="1"
      marker-end="url(#a1)"/>

<!-- Branch label -->
<text x="230" y="52" font-size="11" fill="var(--accent-green)">Yes</text>
```

Place branch labels ("Yes"/"No") slightly above the arrow line, not on it.

## Common Box Patterns

### Single-line box (44px tall)
```svg
<rect x="100" y="20" width="160" height="44" rx="8"
      fill="var(--accent-blue-bg)" stroke="var(--accent-blue)" stroke-width="0.5"/>
<text x="180" y="46" text-anchor="middle"
      font-size="13" font-weight="600" fill="var(--accent-blue-text)">Label</text>
```

### Two-line box (52-56px tall)
```svg
<rect x="100" y="20" width="200" height="52" rx="8"
      fill="var(--accent-blue-bg)" stroke="var(--accent-blue)" stroke-width="0.5"/>
<text x="200" y="42" text-anchor="middle"
      font-size="13" font-weight="600" fill="var(--accent-blue-text)">Label</text>
<text x="200" y="60" text-anchor="middle"
      font-size="11" fill="var(--accent-blue-text)" opacity="0.75">Description</text>
```

### Dashed container (for grouping)
```svg
<rect x="20" y="10" width="880" height="200" rx="12"
      fill="none" stroke="var(--border-default)"
      stroke-width="0.5" stroke-dasharray="4 3"/>
```

## Anti-Patterns

| Don't | Do Instead |
|---|---|
| Label + description side-by-side on same y | Two-line layout (label above, desc below) |
| Hardcoded hex colors | CSS variables |
| viewBox height as round number | Calculate from content bounds + 20px |
| Eyeball text fitting in boxes | Calculate: chars × font-size × 0.58 + 24 ≤ rect width |
| Text floating without checking adjacency | 40px gap rule to nearest element |
| `text-anchor="end"` near left edge | Check left edge = x - text_width ≥ 0 |
