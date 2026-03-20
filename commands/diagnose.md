---
description: Investigate bugs, errors, and unexpected behavior — find root cause and suggest fixes with project-aware debugging
---

You are executing the `/diagnose` command.

## Input

Problem: $ARGUMENTS (error message, bug description, or unexpected behavior)

## Workflow

### Step 1: Load Skills

Read and apply:

- `.claude/skills/coding-standards/SKILL.md`
- `.claude/skills/architecture-patterns/SKILL.md`

### Step 2: Detect Project Type

> Project type detection: see `.claude/rules/project-detection.md`

After detection, apply project-specific debug focus:
- **Electron**: IPC errors, process crashes, preload issues, DB errors, worker thread failures
- **Library**: Provider loading, factory errors, action failures, logUpdate issues
- **Server**: API errors, middleware issues, DB queries

### Step 3: Quick Pattern Match

> Check `.claude/rules/error-patterns.md` for all known error patterns before deep investigation.

### Step 4: Investigate

Act as the **debugger** agent (`.claude/agents/debugger.md`).

Follow the agent's full investigation process:

1. **Parse the problem** (expected vs actual behavior)
2. **Locate the error** — determine which process/layer:
   - For Electron: Main process? Preload? Renderer? Worker thread? Database?
   - For Library: Core framework? Provider? Action? HTTP client?
3. **Gather evidence** (search code, trace execution, check git history)
4. **Form 3+ hypotheses** with evidence for/against
5. **Apply 5 Whys** to the most likely cause
6. **Propose solutions** ranked by effort and risk

### Step 5: Trace Cross-Process (Electron)

> Cross-process tracing: the debugger agent (`.claude/agents/debugger.md`) handles the full 6-layer trace automatically.

### Step 6: Report

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
| 2   | <cause B>  | <supporting> | <contradicting>  | High/Med/Low |
| 3   | <cause C>  | <supporting> | <contradicting>  | High/Med/Low |

### Root Cause (5 Whys)
```

Symptom: <the reported problem>
Why 1: <immediate cause>
Why 2: <cause of that cause>
Why 3: <deeper cause>
Why 4: <structural cause>
Why 5: <root cause>

```

### Recommended Solutions

| # | Approach | Effort | Risk | Addresses Root Cause? |
| --- | --- | --- | --- | --- |
| 1 | <quick fix> | Small | Low | Partial |
| 2 | <proper fix> | Medium | Low | Yes |
| 3 | <structural fix> | Large | Medium | Yes + prevents recurrence |

### Prevention

<how to prevent similar issues — coding pattern, type guard, validation, etc.>
```

### Step 7: Fix (If Approved)

If the user approves a solution:

1. Execute with `/implement` command
2. Verify with `npm run flint && npm run typecheck`
3. If the fix was complex, document it: `/generate-docs fix "<issue-name>"`

## Notes

- Always trace the full execution path before concluding
- For Electron: check ALL layers (renderer → preload → main → DB) — the error often surfaces in one layer but originates in another
- For Library: check the provider loading chain (Facade → Loader → Registry → Factory → Provider → Action)
- If the error message is `SOMETHING_WENT_WRONG`, the real error was caught by custom-ipc.ts — look at the actual handler code
- Check git history for recent changes to affected files (`git log --oneline -5 -- <file>`)
- "Regression test" is ideal but conditional — only if test infrastructure exists
- For complex bugs, save diagnosis to `docs/troubleshooting/fix-{issue}.md`
