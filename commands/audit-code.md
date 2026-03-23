---
description: Review code quality, patterns, and anti-patterns in the specified scope with project-aware checks
category: audit
mutates: false
consumes: [source-code]
produces: [review-report]
next: [refactor-plan, audit-naming, implement]
---

You are executing the `/audit-code` command.

## Input

Target: $ARGUMENTS (file, directory, module path, or "recent" for recent changes)

## Workflow

### Step 1: Load Skills

Read and apply:

- `.claude/skills/coding-standards/SKILL.md`
- `.claude/skills/naming-conventions/SKILL.md`
- `.claude/skills/architecture-patterns/SKILL.md`

### Step 2: Detect Project Type

> Project type detection: see `.claude/rules/project-detection.md`

After detection, apply project-specific checks:
- **Electron**: IPC consistency, process isolation, preload mirror
- **Library**: Provider pattern, factory contract, barrel exports
- **Server**: API design, middleware, auth

### Step 3: Discover Scope

Determine what to review:

- **Specific target** -> review that scope: `<target>/**/*.ts`, `<target>/**/*.tsx`
- **"recent" or no target** -> `git diff --name-only HEAD~5`
- **Reviewing a PR** -> `git diff --name-only main...HEAD`

### Step 4: Delegate to Agent

Delegate to the **reviewer** agent (standard mode) with full context from Steps 1-3.
The agent follows its complete review process defined in `.claude/agents/reviewer.md`:

1. Code quality analysis (Critical -> Major -> Minor)
2. Naming audit (E/I prefix, A/HC/LC, S-I-D)
3. Pattern detection (anti-patterns, code smells)
4. Project-type-specific checks (IPC sync, provider pattern, etc.)

### Step 5: Report

Output a structured review report:

```markdown
## Code Review: <scope>

### Project Type: <Electron App / Module Library / Node.js>

### Overview

| Metric          | Count |
| --------------- | ----- |
| Files reviewed  | N     |
| Critical issues | N     |
| Major issues    | N     |
| Minor issues    | N     |

### Critical Issues

1. **[file:line]** <description>
   - **Why**: <explanation of risk>
   - **Fix**: <specific suggestion>

### Major Issues

1. **[file:line]** <description>
   - **Fix**: <specific suggestion>

### Minor Issues

1. **[file:line]** <description>

### Electron Checks (if applicable)

| Check                 | Status | Details   |
| --------------------- | ------ | --------- |
| IPC ↔ Preload sync    | ✅/❌  | <details> |
| Process isolation     | ✅/❌  | <details> |

### Library Checks (if applicable)

| Check              | Status | Details   |
| ------------------ | ------ | --------- |
| Provider structure | ✅/❌  | <details> |
| Factory contract   | ✅/❌  | <details> |

### Positive Highlights

- <things done well>

### Recommendations

- Deep naming -> `/audit-naming`
- Structural issues -> `/refactor-plan`
```

## Notes

- Be specific: always point to file and line
- Be constructive: suggest a fix for every issue
- Prioritize: Critical -> Major -> Minor
- Skip linter-level issues (formatting, semicolons)
- For renderer code, also check `.claude/rules/react.md` patterns
