# Single-File HTML Page Structure

When building a full HTML reference page with multiple sections and embedded SVG diagrams, follow this structure.

## Page Skeleton

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Page Title</title>
<style>
/* Color system — see Color Tokens section below */
/* Layout — see Layout section below */
</style>
</head>
<body>
  <nav><!-- sticky nav with section links --></nav>
  <div class="container">
    <div class="header"><!-- title + subtitle --></div>
    <!-- sections -->
  </div>
  <script>/* nav scroll highlight + smooth scroll */</script>
</body>
</html>
```

## Layout

```css
.container { max-width: 1400px; margin: 0 auto; padding: 32px 40px 80px; }

.card-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);  /* NEVER use auto-fill minmax */
  gap: 20px;
}

.card-full { grid-column: 1 / -1; }

.card-diagram {
  grid-column: 1 / -1;
  padding: 24px 20px;
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}
.card-diagram svg { min-width: 700px; height: auto; }

@media (max-width: 900px) {
  .card-grid { grid-template-columns: 1fr; }
}
```

**Why `repeat(2, 1fr)` not `auto-fill minmax`:** `auto-fill` with minmax creates unpredictable column counts at different screen widths. At 1440px with minmax(380px), you get 3 columns — which creates orphan cards on the last row. Fixed 2-col is predictable and always pairs cards cleanly.

## Card Count Rule

For each section, count regular cards (not card-full, not card-diagram). If the count is **odd**, the last card sits alone in a 2-col grid, leaving a visible empty gap. Fix by promoting the orphan to `card-full` or rebalancing content.

## Section Structure

```html
<div class="section s-purple" id="sectionid">
  <div class="section-header">
    <span class="section-badge">01</span>
    <h2>Section Title</h2>
  </div>
  <div class="card-grid">
    <div class="card card-diagram"><!-- SVG diagram, always first --></div>
    <div class="card"><!-- regular card --></div>
    <div class="card"><!-- regular card --></div>
    <div class="card card-full"><!-- full-width card for wide tables --></div>
  </div>
</div>
```

Note: `scroll-margin-top: 60px` goes on `.section` (which has the `id`), not on any inner element.

## Navigation

```css
nav {
  position: sticky;
  top: 0;
  z-index: 100;
  background: var(--bg-nav);  /* semi-transparent with blur */
  backdrop-filter: blur(12px);
  border-bottom: 1px solid var(--border-light);
  padding: 10px 0;
  overflow-x: auto;
}
```

JS: highlight active section on scroll, smooth scroll on click.

## Tables

Every table must be wrapped:
```html
<div class="table-wrap">
  <table class="compare-table">...</table>
</div>
```

```css
.table-wrap {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  margin: 8px -4px 0;
  padding: 0 4px;
}
.compare-table { min-width: 480px; }
```

## Color Tokens

Define all in `:root` AND in `@media (prefers-color-scheme: dark)`:

```css
:root {
  --bg-primary: #faf9f6;
  --bg-secondary: #f2f0eb;
  --bg-card: #ffffff;
  --bg-code: #f5f3ee;
  --bg-nav: rgba(250,249,246,0.92);
  --text-primary: #1a1a18;
  --text-secondary: #5c5b57;
  --text-tertiary: #8a8985;
  --border-default: #e2e0da;
  --border-light: #eeece6;
  --accent-purple: #534AB7;
  --accent-purple-bg: #EEEDFE;
  --accent-purple-text: #3C3489;
  --accent-teal: #0F6E56;
  --accent-teal-bg: #E1F5EE;
  --accent-teal-text: #085041;
  --accent-coral: #993C1D;
  --accent-coral-bg: #FAECE7;
  --accent-coral-text: #712B13;
  --accent-blue: #185FA5;
  --accent-blue-bg: #E6F1FB;
  --accent-blue-text: #0C447C;
  --accent-green: #3B6D11;
  --accent-green-bg: #EAF3DE;
  --accent-green-text: #27500A;
  --accent-amber: #854F0B;
  --accent-amber-bg: #FAEEDA;
  --accent-amber-text: #633806;
  --accent-red: #A32D2D;
  --accent-red-bg: #FCEBEB;
  --accent-red-text: #791F1F;
}

@media (prefers-color-scheme: dark) {
  :root {
    --bg-primary: #1a1a18;
    --bg-secondary: #242422;
    --bg-card: #2c2c2a;
    --bg-code: #333330;
    --bg-nav: rgba(26,26,24,0.92);
    --text-primary: #e8e6df;
    --text-secondary: #a8a7a1;
    --text-tertiary: #73726c;
    --border-default: #3d3d3a;
    --border-light: #333330;
    --accent-purple: #AFA9EC;
    --accent-purple-bg: #26215C;
    --accent-purple-text: #CECBF6;
    --accent-teal: #5DCAA5;
    --accent-teal-bg: #04342C;
    --accent-teal-text: #9FE1CB;
    --accent-coral: #F0997B;
    --accent-coral-bg: #4A1B0C;
    --accent-coral-text: #F5C4B3;
    --accent-blue: #85B7EB;
    --accent-blue-bg: #042C53;
    --accent-blue-text: #B5D4F4;
    --accent-green: #97C459;
    --accent-green-bg: #173404;
    --accent-green-text: #C0DD97;
    --accent-amber: #EF9F27;
    --accent-amber-bg: #412402;
    --accent-amber-text: #FAC775;
    --accent-red: #F09595;
    --accent-red-bg: #501313;
    --accent-red-text: #F7C1C1;
  }
}
```

## Section Color Classes

Each section gets a color class that themes its badges, bullet dots, and insight boxes:

```css
.s-purple .section-badge { background: var(--accent-purple-bg); color: var(--accent-purple-text); }
.s-purple .card li::before { background: var(--accent-purple); }
.s-purple .insight { border-color: var(--accent-purple); background: var(--accent-purple-bg); color: var(--accent-purple-text); }
/* Repeat for: teal, coral, blue, green, amber, red */
```

## Pre-Delivery QA

Run ALL before presenting:

- [ ] Div/table/SVG tag balance
- [ ] Nav links match section IDs
- [ ] No duplicate IDs
- [ ] Card count per section (no orphans)
- [ ] All tables in scroll wrappers
- [ ] SVG text: no overlap, no clipping (see svg-diagram skill rules)
- [ ] SVG viewBox heights tight
- [ ] All colors use CSS variables
- [ ] scroll-margin-top on .section elements
