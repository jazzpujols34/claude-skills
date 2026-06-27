#!/usr/bin/env python3
"""
wrap.py — make a review copy of an HTML artifact with the annotate overlay inlined.

    python3 wrap.py path/to/page.html            # -> path/to/page.review.html
    python3 wrap.py page.html --out custom.html

Keeps the original CLEAN (deployable). The overlay lives only in the .review.html,
so a deploy that copies `page.html` can never leak the annotate UI to production.
Re-run after every edit to regenerate the review copy; notes persist in the
browser (localStorage keyed by the review filename) across regenerations.

Idempotent: refuses to wrap a file that already contains the overlay.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
OVERLAY = HERE / "overlay.js"
MARKER = "__annotateLoaded"


def wrap(html_path: Path, out_path: Path | None = None, rev: str | None = None) -> Path:
    html = html_path.read_text(encoding="utf-8")
    if MARKER in html:
        raise SystemExit(f"[wrap] {html_path.name} already has the overlay — refusing to double-inline.")
    overlay = OVERLAY.read_text(encoding="utf-8")
    # --rev bumps the localStorage key so a regeneration starts with NO carried-over
    # notes — use it after you've addressed and resolved the previous round, so stale
    # (already-fixed) markers don't reappear pinned to shifted content.
    rev_script = f"<script>window.__annotRev={rev!r};</script>\n" if rev else ""
    block = f"\n<!-- annotate overlay (review only — NOT for production) -->\n{rev_script}<script>\n{overlay}\n</script>\n"

    low = html.lower()
    idx = low.rfind("</body>")
    if idx == -1:
        # no </body> — append at end (still works, mounts on DOMContent)
        new = html + block
    else:
        new = html[:idx] + block + html[idx:]

    if out_path is None:
        out_path = html_path.with_suffix("")  # strip .html
        out_path = out_path.with_name(out_path.name + ".review.html")
    out_path.write_text(new, encoding="utf-8")
    return out_path


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("html", help="clean HTML artifact to wrap")
    ap.add_argument("--out", help="output path (default: <name>.review.html)")
    ap.add_argument("--rev", help="revision tag — bumps the localStorage key so the review copy "
                                  "loads with NO carried-over notes (use after resolving the prior round)")
    args = ap.parse_args()
    src = Path(args.html).resolve()
    if not src.exists():
        print(f"[wrap] not found: {src}", file=sys.stderr)
        return 1
    out = wrap(src, Path(args.out).resolve() if args.out else None, rev=args.rev)
    print(f"[wrap] review copy -> {out}" + (f" (rev {args.rev}: fresh notes)" if args.rev else ""))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
