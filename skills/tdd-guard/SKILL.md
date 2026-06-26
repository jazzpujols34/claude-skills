---
name: tdd-guard
description: Enforce test-first development. Trigger on "write a feature", "add functionality", "implement", or any code task that touches business logic. Auto-activate when writing code without tests. Pairs with debug-loop-breaker (prevention vs cure).
---

# TDD Guard

> No production code without a failing test first. This is the prevention layer — debug-loop-breaker is the cure.

## Detection — When to Activate

Activate this skill when:

- The user asks to build a new feature or add functionality
- You're about to write business logic, API endpoints, or data transformations
- You're fixing a bug (write a test that reproduces it FIRST)
- Any code change that could break existing behavior

**Do NOT activate for:**
- Config files, env vars, styling-only changes
- Documentation, comments, type-only changes
- One-off scripts, migrations, or prototyping (unless the user asks)

## The Protocol

### 1. UNDERSTAND before you code

Read the relevant source files. Identify:
- What function/component will change?
- What are the inputs and expected outputs?
- What are the edge cases?

State this in one sentence: *"I'm going to [change X] so that [Y happens]. The test should verify [Z]."*

### 2. WRITE the failing test first

```
# Create or open the test file adjacent to the source
# __tests__/thing.test.ts  or  test_thing.py
```

Write a test that:
- Describes the DESIRED behavior (not current behavior)
- Is specific: exact inputs → exact expected outputs
- Covers the happy path AND at least one edge case
- **Will fail right now** because the feature doesn't exist yet

### 3. RUN the test — confirm it fails

```bash
# JS/TS
npx vitest run path/to/test --reporter=verbose

# Python
pytest path/to/test -v
```

If the test passes already → your test is wrong (it's not testing new behavior). Rewrite it.

If it errors on import/setup → fix the test infrastructure, not the source code.

### 4. WRITE the minimum code to pass

Write ONLY enough production code to make the failing test pass. No more.

- Don't add error handling for cases you haven't tested
- Don't refactor while implementing
- Don't add features beyond what the test covers

### 5. RUN the test — confirm it passes

```bash
npx vitest run path/to/test --reporter=verbose
# or
pytest path/to/test -v
```

If it fails → fix the production code (not the test, unless the test had a typo).

### 6. RUN all related tests

```bash
# Run the full test suite for the module/project
npx vitest run
# or
pytest
```

If other tests broke → you introduced a regression. Fix it before moving on.

### 7. REFACTOR (optional, only after green)

Now you can clean up — but only with all tests passing. Run tests after every refactor step.

## Bug Fix Protocol

When fixing a bug, the order is strict:

1. **Reproduce** — Write a test that triggers the bug (test should FAIL)
2. **Fix** — Change the minimum code to make the test pass
3. **Verify** — Run all tests to confirm no regressions

Never fix a bug without a test that proves it was broken.

## Enforcement Checkpoints

Before committing any code change, verify:

| Check | Pass? |
|-------|-------|
| New behavior has a corresponding test | |
| Test was written BEFORE the implementation | |
| Test fails without the implementation (confirmed) | |
| Test passes with the implementation | |
| Full test suite passes (no regressions) | |
| No test is skipped or `.only`'d | |

If any check fails, do not commit. Fix it first.

## Anti-Patterns

| Pattern | Problem | Instead |
|---------|---------|---------|
| Writing implementation first, tests after | Tests become "confirmation tests" that just verify what you wrote, not what's correct | Test first — always |
| Testing implementation details | Brittle tests that break on refactor | Test behavior: inputs → outputs |
| `test.skip()` or `@pytest.mark.skip` | Hiding failures | Fix or delete the test |
| Mocking everything | Tests pass but prod breaks | Mock boundaries only (DB, APIs), not internal functions |
| One giant test per feature | Can't tell what broke | One assertion per test case, descriptive names |
| "I'll add tests later" | You won't | Now or never |

## Gotchas

- **Vitest watch mode can mask failures.** Run with `--run` flag for a clean single pass before committing.
- **Python test discovery needs `__init__.py`** in test directories sometimes. If pytest can't find tests, check this.
- **Don't mock the database in integration tests.** Mocked tests can pass while a real migration or query fails in production. Use a real test DB.
- **React component tests:** use `@testing-library/react`, test user interactions not component internals. `screen.getByRole` > `wrapper.find('.class-name')`.
- **FastAPI tests:** use `TestClient` from `starlette.testclient`. It runs synchronously, no need for async test setup.
- **Edge runtime (e.g. Cloudflare Workers):** some Node.js test utilities don't work. Use a local edge emulator (such as Miniflare) for testing edge functions.

## Upgrade Path: Hook-Based Enforcement

This skill is a behavioral guide — it relies on the agent following the protocol. For **hard enforcement** that blocks non-TDD file writes, install the `nizos/tdd-guard` Claude Code plugin:

```bash
# Installs hooks that intercept Write/Edit operations
# Uses a second model to validate TDD compliance
# Blocks file writes that don't follow Red-Green-Refactor
/plugin marketplace add nizos/tdd-guard
/plugin install tdd-guard@tdd-guard
/tdd-guard:setup
```

The plugin intercepts every file write via PreToolUse hooks, validates against TDD rules using a second model call, and blocks non-compliant operations. Adds latency per write but guarantees compliance. Worth it for critical codebases.
