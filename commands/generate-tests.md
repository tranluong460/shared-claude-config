---
description: Generate tests for specified code — bootstrap test infra if needed, then plan and generate tests
category: execute
mutates: true
consumes: [source-code]
produces: [test-files]
next_on_success: [implement]
---

You are executing the `/generate-tests` command.

> Test rules auto-inject via `.claude/rules/testing.md`. Mock patterns and testability guides are in `skills/testing-strategy/SKILL.md`.

## Input

Target: $ARGUMENTS (file path, module, or "setup" to bootstrap only)

## Workflow

### Step 1: Load Skills

- `.claude/skills/testing-strategy/SKILL.md`
- `.claude/skills/coding-standards/SKILL.md`
- `.claude/skills/naming-conventions/SKILL.md`
- `.claude/skills/project-context/SKILL.md` (if filled in)

### Step 2: Detect Test Infrastructure

```
package.json -> vitest/jest in deps?
Glob: vitest.config.*, jest.config.*
Glob: **/*.test.ts, test/**/*.ts
```

| Scenario         | Action                          |
| ---------------- | ------------------------------- |
| Framework exists | Use it, match existing patterns |
| No framework     | Bootstrap vitest (see skill)    |
| Input is "setup" | Bootstrap only, stop            |

### Step 3: Delegate to Agent

Delegate to the **test-architect** agent with full context from Steps 1-2.
The agent follows its complete process defined in `.claude/agents/test-architect.md`:

1. Analyze target (public API, dependencies, edge cases)
2. Create test plan with mock strategy
3. Generate tests following AAA pattern
4. Run and verify

### Step 4: Report

```markdown
## Tests Generated: <target>

| File          | Tests | Passing |
| ------------- | ----- | ------- |
| `<test-file>` | N     | N       |

### Suggested Next Tests

- <what to test next>
```
