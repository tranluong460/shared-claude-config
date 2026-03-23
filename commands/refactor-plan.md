---
description: Analyze code and create a structured refactoring plan with phases, risk assessment, and project-aware recipes
category: plan
mutates: false
consumes: [source-code]
produces: [refactoring-plan]
next_on_success: [generate-tests, implement]
---

You are executing the `/refactor-plan` command.

## Input

Target: $ARGUMENTS (file, module, directory, or description of what to refactor)

## Workflow

### Step 1: Load Skills

Read and apply:

- `.claude/skills/refactoring-strategy/SKILL.md`
- `.claude/skills/architecture-patterns/SKILL.md`
- `.claude/skills/naming-conventions/SKILL.md`

### Step 2: Detect Project Type

> Project type detection: see `.claude/rules/project-detection.md`

After detection, apply project-specific risk factors:
- **Electron**: IPC consistency, preload sync, process isolation, submodule
- **Library**: Provider contract, factory interface, consumer impact
- **Server**: API contract, middleware chain, DB migration

### Step 3: Delegate to Agent

Delegate to the **architect** agent with full context from Steps 1-2.
The agent follows its complete refactoring plan process defined in `.claude/agents/architect.md`:

1. Analyze current state (problem, file count, dependency graph)
2. Determine refactoring scale (Surgical/Module/Architecture)
3. Risk assessment (test coverage, public API change, rollback complexity)
4. Design target state
5. Create phased plan (Foundation -> Migration -> Cleanup -> Verify)

### Step 4: Output Plan

Write the plan to `docs/plans/YYYYMMDD-{plan-name}.md`:

```markdown
## Refactoring Plan: <title>

### Problem

<What's wrong and why it matters>

### Target State

<What it should look like>

### Risk Assessment

| Factor              | Level               | Details             |
| ------------------- | ------------------- | ------------------- |
| Test coverage       | <None/Low/Med/High> | <current state>     |
| Files affected      | <N>                 | <list of key files> |
| Public API change   | <Yes/No>            | <what changes>      |
| Rollback complexity | <Low/Med/High>      | <why>               |

### Phase 1: <Foundation>

- [ ] Task 1: <specific file change>

**Verification**: `npm run flint && npm run typecheck`

### Phase 2: <Migration>

- [ ] Task 2: <specific file change>

### Phase 3: <Cleanup>

- [ ] Task 3: Delete old files, update barrel exports

### Rollback Plan

<How to revert>

### Next Steps

After approval, execute with: `/implement docs/plans/YYYYMMDD-{plan-name}.md`
```

### Step 5: Present for Approval

Present the plan summary and wait for user feedback before any implementation.

## Notes

- Never suggest big-bang rewrites
- Each phase must be independently verifiable
- Include verification commands for every phase
- For Electron: always verify IPC handler <-> preload proxy consistency
- For Library: always run `yarn test` after changes
- Do NOT include time estimates
- Save plan to `docs/plans/` for tracking
