---
description: Analyze code and create a structured refactoring plan with phases, risk assessment, and project-aware recipes
category: plan
mutates: false
consumes: [source-code]
produces: [refactoring-plan]
result_states: [plan_ready, needs_input, execution_error]
next_on_result:
  plan_ready: [test, implement]
  needs_input: []
  execution_error: [audit]
---

You are executing the `/plan` command (formerly `/refactor-plan`).

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
5. Create phased plan (Foundation -> Migration -> Cleanup -> Quality Assurance)

### Step 4: Output Plan Folder

Write the plan as a **folder** under `docs/plans/YYYYMMDD-{plan-name}/` — never a flat `.md` file.

Follow the full plan folder skeleton defined in `.claude/skills/documentation-standards/SKILL.md` §7 (and mirrored in `.claude/commands/docs.md` Step 2c):

```
docs/plans/YYYYMMDD-{plan-name}/
├── overview.md                  # Executive summary (use template below)
├── business-tdd/
│   ├── business.md              # Business problem, users, acceptance criteria
│   └── tdd.md                   # Test cases before code (regression guards!)
├── design/
│   ├── architecture.md          # Current vs target structure (mermaid diagram)
│   ├── execution-plan.md        # Phased breakdown — this is the refactor core
│   ├── impact-analysis.md       # Affected files, blast radius, co-change risks
│   └── risks.md                 # Risks + rollback plan
└── adr/
    └── ADR-001-{strategy}.md    # e.g. "Use Strangler pattern for X"
```

For refactor plans, the phased breakdown lives in `design/execution-plan.md`. Use this template:

```markdown
# Execution Plan

## Problem

<What's wrong and why it matters>

## Target State

<What it should look like after the refactor>

## Risk Assessment

| Factor              | Level               | Details             |
| ------------------- | ------------------- | ------------------- |
| Test coverage       | <None/Low/Med/High> | <current state>     |
| Files affected      | <N>                 | <list of key files> |
| Public API change   | <Yes/No>            | <what changes>      |
| Rollback complexity | <Low/Med/High>      | <why>               |

## Phase 1: Foundation

- [ ] Task 1.1: <specific file change>

**Verification**: `npm run flint && npm run typecheck`

## Phase 2: Migration

- [ ] Task 2.1: <specific file change>

## Phase 3: Cleanup

- [ ] Task 3.1: Delete old files, update barrel exports

## Phase 4: Quality Assurance

- [ ] Lint + typecheck
- [ ] Full test suite
- [ ] Update `docs/onboarding/04-core-modules.md` if module layout changed
- [ ] Update `docs/user-guide/` feature-area files if user-visible behavior changed

## Next Steps

After approval, execute with: `/implement docs/plans/YYYYMMDD-{plan-name}/`
```

`design/risks.md` must contain the rollback plan. `design/impact-analysis.md` must list every affected file with risk level.

### Step 5: Present for Approval

Present the `overview.md` summary and the `execution-plan.md` phase list. Wait for user feedback before any implementation.

## Notes

- Never suggest big-bang rewrites
- Each phase must be independently verifiable
- Include verification commands for every phase
- For Electron: always verify IPC handler <-> preload proxy consistency
- For Library: always run `yarn test` after changes
- Do NOT include time estimates
- Save plan as a **folder** under `docs/plans/YYYYMMDD-{name}/` — never a flat `.md` file
- If the refactor changes public modules or user-visible behavior, queue follow-up updates to `docs/onboarding/04-core-modules.md` and the relevant `docs/user-guide/NN-{feature-area}.md` files (add them as tasks in Phase 4)
