# tdd-guard

> Keep an AI coding agent on the test-first path: a failing test before any production code, every time.

**What it does.** Gives the agent a strict Red-Green-Refactor protocol so it writes the test first, watches it fail, writes the minimum code to pass, then runs the full suite to catch regressions. It includes a bug-fix order (reproduce → fix → verify), an enforcement checklist to run before committing, and an anti-pattern table for the usual ways TDD gets faked. It is the prevention layer; the `debug-loop-breaker` skill is the cure when fixes start looping.

**Install.** Copy the folder into your Claude Code skills directory:
```bash
cp -r skills/tdd-guard ~/.claude/skills/
```
Then trigger it by describing a code task in your own words — "write a feature", "add functionality", "implement X", "fix this bug". The skill listens for those (see the `description` in [`SKILL.md`](SKILL.md)).

**Example.** Ask "add a function that parses a date range" → the agent first writes a failing `test_parse_range` with exact inputs/outputs and one edge case, runs it to confirm RED, writes just enough code to go GREEN, then runs the whole suite before touching anything else.

**Dependencies.** None. The protocol is editor-agnostic and works with whatever test runner your project already uses (examples use Vitest and pytest). An optional hard-enforcement upgrade path (the `nizos/tdd-guard` Claude Code plugin) is described at the end of `SKILL.md`.
