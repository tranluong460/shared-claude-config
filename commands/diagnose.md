---
description: Investigate bugs, errors, and unexpected behavior — find root cause and suggest fixes with project-aware debugging
category: analyze
mutates: false
consumes: [error-description, source-code]
produces: [diagnosis-report]
next_on_success: [generate-tests, implement]
---

You are executing the `/diagnose` command.

## Input

Problem: $ARGUMENTS (error message, bug description, or unexpected behavior)

## Workflow

### Step 1: Load Skills

Read and apply:

- `.claude/skills/coding-standards/SKILL.md`
- `.claude/skills/architecture-patterns/SKILL.md`
- `.claude/rules/testing-methodology.md` — follow the 4-step analysis process (Input Assumptions -> Flow Analysis -> Report -> then diagnose)
- `.claude/skills/project-context/SKILL.md` (if filled in)

### Step 2: Detect Project Type

> Project type detection: see `.claude/rules/project-detection.md`

After detection, apply project-specific debug focus:
- **Electron**: IPC errors, process crashes, preload issues, DB errors, worker thread failures
- **Library**: Provider loading, factory errors, action failures, logUpdate issues
- **Server**: API errors, middleware issues, DB queries

### Step 3: Quick Pattern Match

> Check `.claude/rules/error-patterns.md` for all known error patterns before deep investigation.

### Step 4: Delegate to Agent

Delegate to the **debugger** agent with full context from Steps 1-3.
The agent follows its complete investigation process defined in `.claude/agents/debugger.md`:

1. Parse the problem (expected vs actual behavior)
2. Locate the error layer
3. Gather evidence
4. Form 3+ hypotheses with evidence
5. Apply 5 Whys to the most likely cause
6. Propose solutions ranked by effort and risk

### Step 5: Report

Present findings:

```markdown
## Diagnosis: <problem summary>

### Error Location

| Layer        | File                  | Status        |
| ------------ | --------------------- | ------------- |
| Renderer     | src/renderer/...      | ✅ OK         |
| Preload      | src/preload/...       | ✅ OK         |
| Main Handler | src/main/ipc/...      | ❌ Error here |
| Database     | src/main/database/... | ✅ OK         |

### Evidence

<what was found — code references with file:line, log output, traces>

### Hypotheses

| #   | Hypothesis | Evidence For | Evidence Against | Likelihood   |
| --- | ---------- | ------------ | ---------------- | ------------ |
| 1   | <cause A>  | <supporting> | <contradicting>  | High/Med/Low |

### Root Cause (5 Whys)
```

Symptom: <the reported problem>
Why 1: <immediate cause>
Why 2-5: <chain to root cause>

```

### Recommended Solutions

| # | Approach | Effort | Risk | Addresses Root Cause? |
| --- | --- | --- | --- | --- |
| 1 | <quick fix> | Small | Low | Partial |
| 2 | <proper fix> | Medium | Low | Yes |

### Prevention

<how to prevent similar issues>
```

### Step 6: Fix (If Approved)

If the user approves a solution:

1. Execute with `/implement` command
2. Verify with `npm run flint && npm run typecheck`

## Notes

- Always trace the full execution path before concluding
- For Electron: check ALL layers (renderer -> preload -> main -> DB)
- If the error message is `SOMETHING_WENT_WRONG`, the real error was caught by custom-ipc.ts
- Check git history for recent changes to affected files
