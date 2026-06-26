# debug-loop-breaker

> A circuit breaker for debugging that's gone in circles — stop guessing, run a systematic diagnosis instead.

**What it does.** When the same error keeps coming back and fixes keep failing, this skill makes the agent stop writing code and run a fixed protocol instead: state the exact error, list every assumption, verify each one with a real command, isolate the smallest reproduction, then make a single hypothesis-driven change at a time. After three failed cycles it escalates with evidence rather than guessing a fourth time.

**Install.** Copy the folder into your Claude Code skills directory:
```bash
cp -r skills/debug-loop-breaker ~/.claude/skills/
```

**How to trigger it.** It fires on the signals of a stuck debugging session — say "still not working", "same error", "that didn't fix it", or "try again" a second time, and the agent switches into the protocol. You can also invoke it explicitly: "we're going in circles, break the debug loop."

**Dependencies.** None. Pure process — no scripts, no packages, no API key.
