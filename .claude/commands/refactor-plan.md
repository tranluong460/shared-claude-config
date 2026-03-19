---
description: Analyze code and create a structured refactoring plan with phases, risk assessment, and project-aware recipes
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

### Step 3: Analyze Current State

Act as the **architect** agent (`.claude/agents/architect.md`).

#### 3a. Understand the Problem

Read the target code and identify:

- What's wrong with the current structure?
- How many files are affected?
- What's the dependency graph?

Scan for references:

```
# Find all files in scope
Glob: <target>/**/*.ts, <target>/**/*.tsx

# Find references to the target module
Grep: import.*from.*<module> (across src/)

# Find who depends on this code
Grep: <exported-name> (across src/)
```

#### 3b. Determine Refactoring Scale

| Scale            | Files | Strategy                                                    |
| ---------------- | ----- | ----------------------------------------------------------- |
| **Surgical**     | 1-3   | Extract/rename/simplify — no formal plan needed, just do it |
| **Module**       | 3-10  | Phased plan with verification at each step                  |
| **Architecture** | 10+   | ADR required first, phased plan, Strangler/Facade pattern   |

If scale is **Surgical** → skip to Step 6, create a simple plan and execute.

#### 3c. Risk Assessment

**General factors:**

| Factor              | Level             | Details                         |
| ------------------- | ----------------- | ------------------------------- |
| Test coverage       | None/Low/Med/High | Current state for affected code |
| Files affected      | N                 | Number of files to change       |
| Public API change   | Yes/No            | Does this break consumers?      |
| Data migration      | Yes/No            | Schema or storage changes?      |
| Rollback complexity | Low/Med/High      | How easy to revert?             |

**Electron-specific factors** (if applicable):

| Factor                | Level                 | Details                                |
| --------------------- | --------------------- | -------------------------------------- |
| IPC channels affected | N                     | Channels that change or move           |
| Preload proxy sync    | Yes/No                | Must update preload to match main?     |
| Cross-process impact  | Main/Preload/Renderer | Which processes are affected?          |
| Submodule impact      | Yes/No                | Does this touch mkt-core?              |
| Window lifecycle      | Yes/No                | Does this affect app startup/shutdown? |
| Worker thread impact  | Yes/No                | Does this affect job execution?        |
| Entity/DB change      | Yes/No                | TypeORM entity modifications?          |

**Library-specific factors** (if applicable):

| Factor                   | Level  | Details                                     |
| ------------------------ | ------ | ------------------------------------------- |
| Provider contract change | Yes/No | Does ILabsProviderFactory interface change? |
| Consumer impact          | N      | How many projects consume this library?     |
| Factory interface stable | Yes/No | Does the factory create() signature change? |
| Enum change              | Yes/No | Does EnumLabsProvider need new values?      |
| Base class change        | Yes/No | Does LabsBaseClass change?                  |

### Step 4: Design Target State

Define what the code should look like after refactoring:

- New module structure (tree diagram)
- Dependency changes (what imports change)
- Pattern changes (old pattern → new pattern)
- Type improvements (I prefix, E prefix, etc.)
- IPC channel changes (if Electron)
- Provider structure changes (if Library)

### Step 5: Create Phased Plan

#### Phase Structure

```
Phase 0: Safety Net (if needed)
  → Add characterization tests / verify existing behavior
  → Only if test infrastructure exists

Phase 1: Foundation
  → Create new structures, interfaces, types
  → No old code removed yet — old and new coexist

Phase 2: Migration
  → Move logic from old to new structure
  → Update imports and references
  → Verify at each step

Phase 3: Cleanup
  → Remove old code
  → Update documentation
  → Final verification

Phase 4: Verify
  → Run full verify suite
  → Check IPC consistency (Electron)
  → Check provider compliance (Library)
```

### Step 6: Generate Plan Document

Write the plan to `docs/plans/YYYYMMDD-{plan-name}.md`:

```markdown
## Refactoring Plan: <title>

### Problem

<What's wrong and why it matters — concrete evidence, not opinions>

### Target State

<What it should look like — include tree diagrams if structural>

### Risk Assessment

| Factor              | Level               | Details             |
| ------------------- | ------------------- | ------------------- |
| Test coverage       | <None/Low/Med/High> | <current state>     |
| Files affected      | <N>                 | <list of key files> |
| Public API change   | <Yes/No>            | <what changes>      |
| Rollback complexity | <Low/Med/High>      | <why>               |
| <project-specific>  | ...                 | ...                 |

### Impact Analysis

#### Direct Impact

- `<file>`: <how it's affected>

#### Indirect Impact

- `<module>`: <depends on affected code>

#### IPC Impact (Electron)

| Channel          | Change  | Main | Preload | Renderer |
| ---------------- | ------- | ---- | ------- | -------- |
| `account_create` | Renamed | ✅   | ✅      | ✅       |

#### Provider Impact (Library)

| Provider  | Change   | Factory | Provider | Actions   |
| --------- | -------- | ------- | -------- | --------- |
| automated | Modified | No      | Yes      | 2 actions |

### Prerequisites

- [ ] Create branch from main/dev
- [ ] Verify current code compiles (`npm run typecheck`)
- [ ] Read existing patterns in affected area

### Phase 1: <Foundation>

**Goal**: <what this phase achieves>

- [ ] Task 1: <specific file change with file path>
- [ ] Task 2: <specific file change>

**Verification**: `npm run flint && npm run typecheck`

### Phase 2: <Migration>

**Goal**: <what this phase achieves>

- [ ] Task 3: <specific file change>
- [ ] Task 4: <specific file change>

**Verification**: `npm run flint && npm run typecheck`
<For Electron: verify IPC handler ↔ preload proxy consistency>
<For Library: yarn test>

### Phase 3: <Cleanup>

**Goal**: Remove old code, update docs

- [ ] Task 5: Delete old files
- [ ] Task 6: Update barrel exports
- [ ] Task 7: Update documentation (if API changed)

**Verification**: Full verify suite + manual smoke test

### Rollback Plan

<How to revert — usually: `git revert` or `git reset` to pre-refactor commit>

### Next Steps

After approval, execute with: `/implement docs/plans/YYYYMMDD-{plan-name}.md`
```

### Step 7: Present for Approval

Present the plan summary and wait for user feedback before any implementation.

If risk is **High on 2+ factors**, recommend:

1. Create an ADR first (`/generate-docs adr "<decision>"`)
2. Consider Strangler Pattern instead of direct refactoring
3. Break into smaller independent refactoring PRs

## Notes

- Never suggest big-bang rewrites
- Each phase must be independently verifiable
- Include verification commands for every phase (`npm run flint && npm run typecheck`)
- For Electron: always verify IPC handler ↔ preload proxy consistency after changes
- For Library: always run `yarn test` after changes
- If the target has NO tests and is high risk, Phase 0 should be "add characterization tests" (only if test infra exists)
- If no test infrastructure exists (e.g., mkt-elec-2025), rely on typecheck + manual verification
- Do NOT include time estimates — focus on scope and risk
- Save plan to `docs/plans/` for tracking
- After approval, suggest `/implement` to execute the plan
