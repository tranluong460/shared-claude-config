---
description: Generate tests for specified code — bootstrap test infra if needed, then plan and generate tests
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

### Step 2: Detect Test Infrastructure

```
package.json → vitest/jest in deps?
Glob: vitest.config.*, jest.config.*
Glob: **/*.test.ts, test/**/*.ts
```

| Scenario         | Action                          |
| ---------------- | ------------------------------- |
| Framework exists | Use it, match existing patterns |
| No framework     | Bootstrap vitest (see skill)    |
| Input is "setup" | Bootstrap only, stop            |

### Step 3: Analyze Target

Act as **test-architect** agent. For target code:

1. Read source files
2. Identify public API surface
3. Identify dependencies (what to mock)
4. Identify edge cases

### Step 4: Test Plan

```markdown
## Test Plan: <module>

| #   | Function    | Scenario                      | Type | Priority |
| --- | ----------- | ----------------------------- | ---- | -------- |
| 1   | `functionA` | Valid input → expected output | Unit | High     |
| 2   | `functionA` | Invalid input → throws        | Unit | High     |

### Mock Strategy

| Dependency   | Mock? | Why             |
| ------------ | ----- | --------------- |
| TypeORM repo | Yes   | External DB I/O |
```

### Step 5: Generate & Verify

Write tests following AAA pattern. Run `yarn test` or `yarn vitest run <file>`.

### Step 6: Report

```markdown
## Tests Generated: <target>

| File          | Tests | Passing |
| ------------- | ----- | ------- |
| `<test-file>` | N     | N       |

### Suggested Next Tests

- <what to test next>
```
