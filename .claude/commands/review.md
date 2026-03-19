---
description: Review code quality, patterns, and anti-patterns in the specified scope with project-aware checks
---

You are executing the `/review` command.

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

**If specific target given** → review that scope:

```
<target>/**/*.ts
<target>/**/*.tsx

# Exclude
**/node_modules/**
**/dist/**
**/out/**
**/*.d.ts
```

**If "recent" or no target** → review recently changed files:

```bash
git diff --name-only HEAD~5
```

**If reviewing a PR** → review all changed files in the branch:

```bash
git diff --name-only main...HEAD
```

### Step 4: Classify by Context (Electron)

For Electron projects, classify each file by process context:

| Context      | Path              | Special rules                                     |
| ------------ | ----------------- | ------------------------------------------------- |
| Main process | `src/main/**`     | No renderer imports, no DOM APIs                  |
| Preload      | `src/preload/**`  | Must mirror main/ipc/, no business logic          |
| Renderer     | `src/renderer/**` | No Node.js imports, no direct IPC                 |
| Shared core  | `**/mkt-core/**`  | Must work in both main and renderer               |
| Types        | `**/types/**`     | I prefix for interfaces/types, E prefix for enums |

### Step 5: Review

Act as the **code-reviewer** agent (`.claude/agents/code-reviewer.md`).

Apply the agent's full review process:

1. **Code quality analysis** — severity categorization (Critical → Major → Minor)
2. **Naming audit** — E/I prefix, A/HC/LC, S-I-D, IPC naming
3. **Pattern detection** — anti-patterns, code smells
4. **Project-type-specific checks** (see below)

#### Electron-Specific Checks

> Enforcement: `.claude/rules/electron.md`

| Check                      | Severity | What to look for                                              |
| -------------------------- | -------- | ------------------------------------------------------------- |
| IPC handler ↔ preload sync | Critical | Every main/ipc/ handler must have matching preload/ipc/ proxy |
| Process isolation          | Critical | No `require()` or Node.js imports in renderer                 |
| Context bridge bypass      | Critical | Renderer must use `window.api`, never `ipcRenderer` directly  |
| IPC channel naming         | Major    | Must follow `{domain}_{actionCamelCase}` pattern              |
| Fat IPC handler            | Major    | Handler > 100 lines → suggest extracting service              |
| React Query patterns       | Major    | Correct queryKey, proper invalidation, error handling         |
| Hook naming                | Minor    | Must follow `use` + PascalCase                                |
| Missing preload type       | Minor    | IPC args/return should be typed in preload/types/             |

#### Library-Specific Checks

> Provider structure: see `.claude/rules/provider-pattern.md`

| Check             | Severity | What to look for                                     |
| ----------------- | -------- | ---------------------------------------------------- |
| Factory contract  | Critical | Must implement `ILabsProviderFactory`                |
| Base class usage  | Major    | Actions must extend `LabsBaseClass`                  |
| Barrel exports    | Major    | Every directory must have `index.ts` with exports    |
| LogUpdate usage   | Major    | Actions must use `this.logUpdate()`, not console.log |
| Public vs private | Minor    | Internal utils should be in `utils/private/`         |

### Step 6: Report

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
   - **Fix**: <specific suggestion with code example if helpful>

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
| IPC naming convention | ✅/❌  | <details> |

### Library Checks (if applicable)

| Check              | Status | Details   |
| ------------------ | ------ | --------- |
| Provider structure | ✅/❌  | <details> |
| Factory contract   | ✅/❌  | <details> |
| Barrel exports     | ✅/❌  | <details> |

### Positive Highlights

- <things done well — always acknowledge good patterns>

### Recommendations

- <prioritized actionable next steps>
- For deep naming audit → run `/audit-naming <scope>`
- For structural issues → run `/refactor-plan <scope>`
```

## Notes

- Be specific: always point to file and line
- Be constructive: suggest a fix for every issue
- Be balanced: acknowledge good patterns alongside issues
- Prioritize: Critical → Major → Minor
- Skip linter-level issues (formatting, semicolons) — that's the linter's job
- For Electron: always check IPC handler ↔ preload proxy consistency
- For Library: always check provider pattern compliance
- When naming issues are pervasive, recommend `/audit-naming` for deep audit
- When structural issues are found, recommend `/refactor-plan` for planning
