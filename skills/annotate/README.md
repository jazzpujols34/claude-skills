# annotate

> Add a click-to-comment layer to any HTML artifact so a human can leave inline notes that copy back out as a ready-to-paste revision prompt.

**What it does.** HTML-producing skills emit pages one-way; this adds the human → agent feedback channel back. Drop a single inlined `<script>` into any HTML artifact (a plan, spec, review, or report) and a reviewer can click or text-select any part of it, type what should change, and hit **Copy as prompt** — which produces a structured prompt you paste straight back into the agent. Each note carries the nearest heading plus the clicked/selected snippet, so the agent can locate the target without screenshots or line numbers. Zero server, zero dependencies, zero network; notes persist in `localStorage` keyed by filename, so they survive reload and re-generation of the same file.

**Install.** Copy the folder into your Claude Code skills directory:
```bash
cp -r skills/annotate ~/.claude/skills/
```
Then trigger it in your own words — "annotate this", "leave notes on it", "make this commentable" — when producing a plan/spec/review/report HTML that someone will critique.

**Use it.** Two ways to apply the overlay:

1. **Inline directly.** Paste the full body of `overlay.js` inside a `<script>` tag placed immediately before `</body>`, after the page's own scripts. It self-mounts a launcher button (bottom-right) and a notes panel. Never `<script src="overlay.js">` it — single-file artifacts are often opened via `file://`, so an external src won't resolve once the file is moved or shared.

2. **Wrap a clean file.** Keep the original deployable and generate a separate review copy:
   ```bash
   python3 wrap.py path/to/page.html            # -> path/to/page.review.html
   python3 wrap.py page.html --out custom.html  # custom output path
   python3 wrap.py page.html --rev 2026-06-27   # fresh storage key (drop carried-over notes)
   ```
   The overlay lives only in the `.review.html`, so a deploy that copies `page.html` can never leak the annotate UI to production. Annotate the `.review.html`, ship the clean `.html`. It's idempotent (refuses to double-inline); re-run after each edit to refresh.

The loop: agent emits HTML → reviewer clicks **✎ Annotate**, marks parts, types notes → clicks **Copy as prompt** → pastes the feedback back into the session → agent revises and re-emits. See [`SKILL.md`](SKILL.md) for triggering and the full Gotchas list.

**Dependencies.** `python3` for the optional `wrap.py` helper. The overlay itself (`overlay.js`) needs nothing — it's plain inline browser JavaScript with no runtime, no build step, and no network.

## Credits

Original concept by **Kun Chen's Lavish** — the file-path-keyed, click-to-annotate review loop. This skill is an independent, dependency-free reimplementation: no server, no telemetry, no external runtime, just a single inlined `<script>`.
