---
description: Independent code review in isolated worktree — catches issues the original author missed
category: verify
mutates: false
consumes: [git-diff]
produces: [review-report]
result_states: [approved, changes_requested, blocked]
next_on_result:
  approved: [generate-docs, reflect]
  changes_requested: [implement]
  blocked: [diagnose]
---

You are executing the `/parallel-review` command.

## Input

Target: $ARGUMENTS (branch name, commit range, or "latest" for HEAD~1)

## Workflow

### Step 1: Load Skills

Read and apply:

- `.claude/skills/coding-standards/SKILL.md`
- `.claude/skills/naming-conventions/SKILL.md`
- `.claude/skills/architecture-patterns/SKILL.md`
- `.claude/skills/testing-strategy/SKILL.md`

### Step 2: Determine Diff Scope

| Input          | Git command                          |
| -------------- | ------------------------------------ |
| "latest"       | `git diff HEAD~1`                    |
| Branch name    | `git diff main...<branch>`          |
| Commit range   | `git diff <range>`                   |
| No input       | `git diff HEAD~1` (default: latest)  |

### Step 3: Launch Independent Review

Spawn the **reviewer** agent in independent mode (`.claude/agents/reviewer.md`) with worktree isolation:

- The agent runs in a separate worktree with fresh context
- It has NO knowledge of why the code was written — eliminating confirmation bias
- It reviews purely based on code quality, patterns, and correctness

### Step 4: Present Results

Display the agent's review output directly. If critical issues are found, recommend running `/implement` to fix them.

## Notes

- This command is designed to be run AFTER `/implement` or manual code changes
- The reviewer agent has no access to the original task context — this is intentional
- For best results, commit your changes first so the diff is clean
- Use this as a final quality gate before creating a PR
