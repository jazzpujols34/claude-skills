---
name: annotate
description: Add an inline-annotation layer to any HTML artifact so you can click/select parts of a plan, spec, review, or report and leave notes that copy back as a ready-to-paste prompt. The INPUT half of HTML-output workflows — pairs with HTML-producing skills like post-to-visual and svg-diagram. Use when producing a plan/spec/review/report HTML that someone will critique, or when asked to "annotate", "leave notes on", "review-in-place", or "make this commentable". Inspired by Kun Chen's Lavish, minus the server/telemetry/dependency.
---

# Annotate

Closes the one gap in HTML-output workflows: HTML-producing skills emit HTML one-way; this adds the
human → agent feedback channel back. No server, no Node runtime, no telemetry, no dependency — a
single inlined `<script>`. A reviewer annotates in the browser, clicks **Copy as prompt**, and pastes
the result back into the agent. Pairs naturally with HTML-producing skills like `post-to-visual` and
`svg-diagram`.

## When to use
- Any **plan / spec / design exploration / code-review writeup / research report** HTML that someone
  will read and want changed. Default-include it for those.
- Skip for: slide decks meant for presenting, final published pages, and anything going into git PR
  review as Markdown.

## How to apply
Inline the entire contents of `overlay.js` (this skill's folder) inside a `<script>` tag placed
**immediately before `</body>`**. It must be inlined, not `<script src>`'d — artifacts are
single-file and often opened via `file://`. Nothing else is required; it self-mounts a launcher
button (bottom-right) and a notes panel.

## The loop
1. Agent emits the HTML artifact with the overlay inlined.
2. The reviewer opens it, clicks **✎ Annotate**, clicks or text-selects any part, and types what
   should change.
3. Notes persist in `localStorage` keyed by filename — survive reload, survive re-generation of the
   same file.
4. The reviewer clicks **Copy as prompt** → pastes the structured feedback into the session → agent
   revises.

## Output format (what Copy as prompt produces)
```
Revise **<filename>** based on my inline review notes:

1. Section "<nearest heading>" → on "<clicked text / selection>":
   <comment>
```
Each note carries the nearest heading + the clicked/selected text snippet, so the agent can locate
the target without screenshots or line numbers.

## Reusable wrapper (for pipelines that keep a clean deployable)
`python3 wrap.py <page.html>` writes `<page>.review.html` with the overlay inlined, leaving the
original clean. Use it when the source must stay overlay-free for deploy (e.g. pages that get copied
straight to production): annotate the `.review.html`, ship the clean `.html`. Idempotent (refuses to
double-inline); re-run after each edit to refresh (notes persist, localStorage-keyed by review
filename).

## Gotchas
- **Inline only.** `<script src="overlay.js">` breaks for `file://` single-file artifacts and when
  the HTML is shared/moved. Paste the full script body in.
- **`file://`-resilient.** `localStorage.setItem` is try/catch-wrapped and the clipboard API guarded,
  so opening a review file via `file://` doesn't silently kill note creation. The original bug: an
  unguarded `save()` threw on the very click that creates a note (Safari blocks `file://` storage;
  Chrome throws when site-data is restricted) → looked like "can't edit".
- **Place before `</body>`**, after the page's own scripts, so it mounts on top of the final DOM.
- **localStorage key is the filename**, not the path. Two different artifacts with the same basename
  in different folders share a note store — rename if that ever collides.
- **Stale notes reappear after you fix a round.** Because the key is the filename, regenerating the
  same `*.review.html` reloads the PREVIOUS round's notes — including ones already resolved. After
  content shifts (e.g. a section was inserted), those markers re-pin to the wrong place and look like
  garbage. Fix: once a round is addressed, regenerate with **`--rev <tag>`** (e.g. a date) — it
  injects `window.__annotRev` so the overlay uses a fresh storage key and the review copy opens clean.
  Bump the tag each round you resolve. (Per-note **delete** and **Clear** buttons also exist in the
  panel for manual control, but `--rev` is the no-touch fix from the build side.)
- **Armed mode swallows clicks** (preventDefault) so links/buttons won't fire while annotating; that
  is intentional. Toggle **✓ Done** to use the page normally again.
- The panel chrome is light-themed by design (it's UI, not content) — it stays readable over both
  light and dark artifacts; don't try to theme it to the page.
- Don't double-inline; the script guards on `window.__annotateLoaded` but keep it to one copy.
- It captures the **nearest preceding heading** for context — if a section has no heading the note
  shows "(top)"; that's fine, the snippet still locates it.

## Credit
Inspired by Kun Chen's Lavish (the file-path-keyed annotation loop). This is an independent,
dependency-free reimplementation — no server, no telemetry, no external runtime.
