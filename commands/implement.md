---
description: Execute implementation tasks — refactoring, bug fixes, or feature additions with project-aware recipes
category: execute
mutates: true
consumes: [plan, source-code]
produces: [code-changes]
next_on_success: [parallel-review]
next_on_fail: [diagnose]
---

You are executing the `/implement` command.

> Implementation rules auto-inject via `.claude/rules/implementation.md`, `rules/ipc.md`, `rules/electron.md`. Focus on recipe selection and execution.

## Input

Target: $ARGUMENTS (task description, plan file, or specific change)

## Workflow

### Step 1: Delegate to Agent

Delegate to the **task-executor** agent with full context from the input and environment detection.

### Step 1b: Load Skills

- `.claude/skills/coding-standards/SKILL.md`
- `.claude/skills/naming-conventions/SKILL.md`
- `.claude/skills/architecture-patterns/SKILL.md`
- `.claude/skills/testing-strategy/SKILL.md`
- `.claude/skills/project-context/SKILL.md` (if filled in)

### Step 2: Detect Environment

- Package manager: `yarn.lock` → yarn
- Project type: Electron / Library / Server
- Verify commands: `npm run flint` → `npm run typecheck` → `yarn test`

### Step 3: Read & Understand

1. Read task description / plan
2. **Read existing similar code** — match patterns exactly
3. Identify all affected files
4. Before implementing, follow `.claude/rules/testing-methodology.md` — Step 1 (Input Assumptions) and Step 2 (Flow Analysis) are required before Step 4 (Implementation)
5. Choose recipe below

### Step 4: Implementation Recipes

#### New IPC Feature (Electron)

> IPC sync steps: follow `.claude/rules/ipc.md` (all 8 layers must sync)

#### New Entity (Electron) — 5 steps

```
1. database/entities/{Entity}Entity.ts → @Entity + CommonEntity
2. Add to EEntityName enum
3. Register in AppDataSource.ts
4. database/models/{Entity}.ts → {Entity}Model object
5. IPC handlers (follow IPC recipe)
```

#### New Provider (Library)

> Provider structure: see `.claude/rules/provider-pattern.md`

#### New Action (Library) — 3 steps

```
1. providers/{provider}/services/actions/action-{name}.ts → extends LabsBaseClass
2. Export from actions/index.ts
3. Instantiate in provider.ts constructor + call in start()
```

#### Refactoring / Bug Fix

```
1. Read existing code → 2. Grep references → 3. Change one thing at a time → 4. Typecheck after each step
```

### Step 5: Verify

```bash
npm run flint && npm run typecheck
yarn test  # if available
```

### Step 6: Report

```markdown
## Implementation Complete: <task>

### Changes Made

- `<file>`: <what changed>

### Recipe Used: <name>

### Quality Checks

| Check     | Result    |
| --------- | --------- |
| flint     | ✅/❌     |
| typecheck | ✅/❌     |
| test      | ✅/❌/N/A |
```
