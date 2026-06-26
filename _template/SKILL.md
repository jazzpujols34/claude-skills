---
name: SKILL_NAME
description: One or two sentences a model uses to decide WHEN to trigger this skill. Lead with the job to be done, then the trigger phrases ("draw a diagram", "audit security"...), then what it is NOT for. Be concrete — this string is the whole routing signal.
---

# SKILL_NAME

One-paragraph statement of what the skill produces and the single most important
rule for using it well.

## When to use

- Bullet the concrete situations that should trigger this skill.
- And the ones that should NOT (point at the right alternative).

## How it works

The steps a model follows. Keep them ordered and verifiable. If the skill ships
scripts, show the exact command (relative to the skill folder, never an absolute
machine path).

## Quality checklist

Binary pass/fail checks to run before calling the output done.

## Gotchas

The hard-won edge cases. Every time this skill hits a new failure mode, add a
line here — this section is why the skill beats an ad-hoc prompt.
