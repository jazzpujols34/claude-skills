# teaching-mode

> Turn a coding session into a teaching session — the agent doesn't just produce working code, it makes sure you actually understand it before it calls the job done.

**What it does.** Flips an AI coding agent into teacher mode. Instead of dumping a finished change, it teaches incrementally — eliciting your current understanding before explaining, drilling the *why* 2-3 levels deep, and verifying real comprehension with quizzes (open-ended + multiple choice) rather than "does that make sense?". It tracks a live `UNDERSTANDING.md` checklist across three pillars (the problem, the solution, the broader context) and won't declare the session complete until every item is demonstrated, not just heard.

**Install.** Copy the folder into your Claude Code skills directory:
```bash
cp -r skills/teaching-mode ~/.claude/skills/
```

**How to trigger.** Ask in your own words — "teach me this", "explain what we built", "make sure I get this", "walk me through the change" — or use it as your default mode whenever you're learning new tech or unfamiliar code. Opt out any time with "just ship it", "skip teaching", or "no quiz".

**Dependencies.** None. It uses the agent's built-in `AskUserQuestion` for quizzes and can optionally lean on a `svg-diagram` skill (if installed) when a structure is easier drawn than described.
