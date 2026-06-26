---
name: debug-loop-breaker
description: Use when debugging has gone in circles — same error 2+ times, repeated failed fixes. Auto-trigger on "still not working", "same error", "try again" appearing twice in a session. Stops guessing, forces systematic diagnosis.
---

# Debug Loop Breaker

> Break out of repeated failed fixes. Triggered when the user says "still", "again", "same error", "not working", or "try again" for the 2nd+ time in a session.

## Detection

If you notice any of these signals appearing twice or more in a conversation, **stop coding and switch to this protocol**:

- "still not working"
- "same error"
- "try again"
- "that didn't fix it"
- "again" (in the context of a persistent bug)
- You yourself are about to say "let me try..." for the 3rd time

You are in a **debugging loop**. More code will not save you. Slow down.

## The Protocol

### 1. STOP

Say it out loud: *"We're going in circles. Switching to the debug loop protocol."*

Do not write another line of code until you finish steps 2-5.

### 2. STATE the actual error

Paste the **exact** error message or unexpected behavior. Not a summary. Not "it's failing". The literal output.

If you don't have it, ask the user: *"Can you paste the exact error output?"*

### 3. LIST assumptions

Write out every assumption the current approach relies on. Be paranoid. Examples:

- The server is running on port 3000
- The env var `DATABASE_URL` is set and correct
- The file was saved after the last edit
- The function is actually being called (not a dead code path)
- The dependency version matches what we expect
- The build picked up the latest changes

### 4. VERIFY each assumption

For **every** assumption above, run a concrete command. Not "I believe" — actually check.

```
# Is the server running?
lsof -i :3000

# Is the env var set?
echo $DATABASE_URL

# Is the file saved with our changes?
grep -n "the line we changed" path/to/file

# Is this code path even hit?
# Add a console.log / print and check output

# What version is installed?
npm ls <package> / pip show <package>
```

Mark each assumption as CONFIRMED or BUSTED.

Any BUSTED assumption is your likely root cause. Fix that first.

### 5. ISOLATE

Create the **smallest possible** reproduction:

- A single test that fails
- A curl command that returns the wrong response
- A 5-line script that triggers the bug

If you can't reproduce it in isolation, the bug is in the interaction between components — now you know where to look.

### 6. SINGLE CHANGE

Make **exactly one** change. State your hypothesis before changing anything:

> "I think X is happening because Y. Changing Z should fix it because..."

If you can't articulate the hypothesis, you don't understand the bug yet. Go back to step 4.

### 7. VERIFY

Run the reproduction case from step 5. Did it pass?

- **Yes** -> Run the full original test/flow to confirm. Done.
- **No** -> Back to step 6. This counts as one cycle.

### 8. ESCALATE (after 3 cycles)

If you've done 3 single-change-and-verify cycles and it's still broken:

```
I'M STUCK.

What we know:
- [confirmed assumptions]
- [what each attempt changed and why it didn't work]

What we've ruled out:
- [list]

My best remaining theories:
1. [theory + what would confirm it]
2. [theory + what would confirm it]

What I need from you:
- [specific question or access request]
```

Do not apologize. Do not say "let me try one more thing." Present the evidence and ask for help.

## Anti-Patterns (call these out when you catch yourself)

| Pattern | What's actually happening | Instead |
|---------|--------------------------|---------|
| Changing 3 things at once | Shotgun debugging — you won't know which one fixed it | One change per cycle |
| "Let me try..." with no hypothesis | Guessing | State what you expect and why before touching code |
| Re-reading the same file | Hoping new insight materializes | Read a *different* file — the bug is probably elsewhere |
| Assuming infra is fine | "The DB is definitely running" | Prove it. Run the command. |
| Editing code without running it | Optimism-driven development | Run after every change |
| Blaming the framework/library | Ego protection | 99% of the time it's your code |

## Gotchas

- **The most common false assumption is "the server restarted."** Hot reload doesn't always pick up changes to env vars, config files, or new dependencies. When in doubt, kill and restart.
- **The agent loves to re-read the same file hoping for new insight.** If you've read a file twice and the bug isn't there, the bug is in a different file. Follow the data flow upstream.
- **"Works in dev, breaks in prod" is almost always env vars or CORS.** Check those before anything else.
- **3 failed attempts is the hard limit.** Don't let the agent (or yourself) try a 4th variation of the same approach. Escalate or pivot.

## One-Liner Version

**STOP** -> **STATE** the error -> **LIST** assumptions -> **VERIFY** each one -> **ISOLATE** smallest repro -> **ONE** change with a hypothesis -> **VERIFY** -> after 3 fails, **ESCALATE** with evidence.
