---
description: Audit naming conventions across the project and suggest renames
category: audit
mutates: false
consumes: [source-code]
produces: [naming-report]
result_states: [clean, issues_found, execution_error]
next_on_result:
  clean: []
  issues_found: [implement]
  execution_error: [diagnose]
---

You are executing the `/audit-naming` command.

## Input

Target: $ARGUMENTS (file, directory, or entire project if not specified)

## Workflow

### Step 1: Load Skills

Read and apply:

- `.claude/skills/naming-conventions/SKILL.md`

### Step 2: Determine Scope

Identify the target and scan for source files:

- If target is a file → audit that file only
- If target is a directory → audit all files in that directory
- If no target → audit the entire `src/` directory

Scan patterns:

```
# TypeScript files
**/*.ts

# React component files
**/*.tsx

# Exclude
**/node_modules/**
**/dist/**
**/out/**
**/*.d.ts
```

### Step 3: Classify by Context

Identify which context each file belongs to (determines which rules apply):

| Context          | Path pattern                      | Special rules                        |
| ---------------- | --------------------------------- | ------------------------------------ |
| Main process     | `src/main/**`                     | IPC handlers, services, entities     |
| Preload          | `src/preload/**`                  | IPC proxies must mirror main/ipc/    |
| Renderer (React) | `src/renderer/**`                 | Components, hooks, layouts, Props    |
| Shared core      | `**/mkt-core/**`                  | Must work in both main and renderer  |
| Library/Module   | `src/core/**`, `src/providers/**` | Factory, provider, registry patterns |
| Tests            | `**/__tests__/**`, `**/*.test.ts` | Test naming conventions              |

### Step 4: Audit Categories

Act as the **reviewer** agent focused on naming. Check each category:

#### 4.1 Folder Naming

- [ ] All folders use `kebab-case`
- [ ] No PascalCase, camelCase, or snake_case folders

#### 4.2 File Naming

- [ ] Services: `{entity}.service.ts`
- [ ] Entities: `{Entity}Entity.ts` (PascalCase)
- [ ] React components: `{ComponentName}.tsx` (PascalCase)
- [ ] React hooks: `use{Name}.ts`
- [ ] IPC handlers: `{domain}.ts` (one file per domain)
- [ ] Preload proxies: mirror `main/ipc/` file names
- [ ] Utils/helpers: `kebab-case.ts`
- [ ] Constants: `{domain}.constants.ts` or `enum.ts`
- [ ] Tests: `{source}.test.ts` or `{source}.spec.ts`
- [ ] Barrel exports: `index.ts`
- [ ] Factory: `factory.ts`
- [ ] Provider: `provider.ts`

#### 4.3 Enum Naming

- [ ] All enums start with `E` prefix + PascalCase
- [ ] Members use `UPPER_SNAKE_CASE` or `PascalCase`

#### 4.4 Interface & Type Naming

- [ ] All interfaces start with `I` prefix + PascalCase
- [ ] All type aliases start with `I` prefix + PascalCase
- [ ] **Exception**: React props use `{Component}Props` without `I` prefix
- [ ] Suffix conventions: `Input`, `Result`, `Options`, `Config`, `Payload`, `Handler`, `Fn`

> Naming conventions and examples: see `.claude/skills/naming-conventions/SKILL.md`

#### 4.5 Class Naming

- [ ] PascalCase, no prefix
- [ ] Suffix reflects role: `Service`, `Manager`, `Factory`, `Provider`, `Registry`, `Repository`, `Store`, `Error`
- [ ] Entity classes: plain name or `{Name}Entity`

#### 4.6 Function Naming

- [ ] Follows A/HC/LC pattern: `prefix? + action + highContext + lowContext?`
- [ ] Correct action verb usage:
  - `get` (immediate/sync) vs `fetch` (async/API/DB)
  - `remove` (from collection, reversible) vs `delete` (permanent, DB)
  - `set` (assign value) vs `reset` (restore initial)
  - `create` (new entity) vs `build` (step-by-step) vs `compose` (from existing) vs `generate` (computed)
- [ ] No contractions
- [ ] No context duplication within class methods
- [ ] No vague names: `processData`, `handleStuff`, `doWork`

#### 4.7 Variable Naming

- [ ] `camelCase` for variables
- [ ] `UPPER_SNAKE_CASE` for exported constants
- [ ] Booleans: `is`/`has`/`can`/`should` prefix (always)
- [ ] Collections: plural (`users`, `activeIds`)
- [ ] Single items: singular (`user`, `activeId`)
- [ ] Maps: `entityByKey` or `entityMap`
- [ ] Boundaries: `min`/`max` prefix (`minPosts`, `maxRetries`)
- [ ] Reflects expected result (no negation needed)

#### 4.8 IPC Channel Naming

- [ ] Pattern: `{domain}_{actionCamelCase}`
- [ ] Domain matches module/entity name
- [ ] Action uses camelCase after underscore
- [ ] Uses enum (`EPrefixIpcEnum`) for domain prefixes
- [ ] Preload proxy mirrors exact channel name

#### 4.9 React-Specific Naming (renderer only)

- [ ] Components: PascalCase file and function name
- [ ] Hooks: `use` + PascalCase
- [ ] Layouts: `Layout` + PascalCase
- [ ] Props interfaces: `{Component}Props` (no `I` prefix)
- [ ] Event handlers: `on` + event name (`onUserCreated`)

#### 4.10 Database Fields (entities only)

- [ ] DB columns use `snake_case` (`is_auto`, `created_at`)
- [ ] TypeScript entity class properties match DB convention

#### 4.11 S-I-D Principle Check

- [ ] No single-letter variables (except generics `T`, `K`, `V` and loop vars `i`, `j`)
- [ ] No made-up words or unnatural phrasing
- [ ] Names are short enough to type quickly
- [ ] Names read naturally in English

### Step 5: Report

Generate a structured report:

```markdown
## Naming Audit: <target>

### Summary

| Category                    | Files Scanned | Violations |
| --------------------------- | ------------- | ---------- |
| Folders                     | N             | N          |
| Files                       | N             | N          |
| Enums (E prefix)            | N             | N          |
| Interfaces/Types (I prefix) | N             | N          |
| Classes                     | N             | N          |
| Functions (A/HC/LC)         | N             | N          |
| Variables                   | N             | N          |
| IPC channels                | N             | N          |
| React naming                | N             | N          |
| DB fields                   | N             | N          |
| **Total**                   | **N**         | **N**      |

### Violations by Category

#### Folder Violations

| Current | Suggested | Location |
| ------- | --------- | -------- |
| ...     | ...       | ...      |

#### File Violations

| Current | Suggested | Reason |
| ------- | --------- | ------ |
| ...     | ...       | ...    |

#### Enum Violations (Missing E Prefix)

| Current         | Suggested        | Location                |
| --------------- | ---------------- | ----------------------- |
| `enum Platform` | `enum EPlatform` | src/types/platform.ts:5 |

#### Interface/Type Violations (Missing I Prefix)

| Current                 | Suggested                | Location             |
| ----------------------- | ------------------------ | -------------------- |
| `interface UserService` | `interface IUserService` | src/types/user.ts:10 |

#### Function Violations (A/HC/LC)

| Current         | Suggested                 | Issue     | Location             |
| --------------- | ------------------------- | --------- | -------------------- |
| `processData()` | `transformUserResponse()` | Too vague | src/utils/data.ts:15 |

#### Variable Violations

| Current               | Suggested               | Issue                  | Location       |
| --------------------- | ----------------------- | ---------------------- | -------------- |
| `const active = true` | `const isActive = true` | Missing boolean prefix | src/user.ts:20 |

#### IPC Channel Violations

| Current | Suggested | Issue | Location |
| ------- | --------- | ----- | -------- |
| ...     | ...       | ...   | ...      |

#### Principle Violations (S-I-D / Context Duplication / Contractions)

| Principle   | Current                         | Suggested                   | Location               |
| ----------- | ------------------------------- | --------------------------- | ---------------------- |
| Contraction | `getUsrNme()`                   | `getUserName()`             | src/user.ts:5          |
| Context dup | `userService.getUserSettings()` | `userService.getSettings()` | src/user.service.ts:10 |
| S-I-D       | `const a = 5`                   | `const postCount = 5`       | src/post.ts:3          |

### Positive Highlights

- <patterns done well>

### Rename Commands (Optional)

If approved, generate IDE-safe refactoring commands for each violation.
```

## Notes

- Only flag genuine violations, not style preferences
- Respect project-specific conventions if they're consistent
- Provide exact file:line for every violation
- Group by severity: prefix violations (E/I) > action verb misuse > style issues
- When suggesting renames, ensure no breaking changes (check all imports/references)
- For IPC renames: both main handler AND preload proxy must be renamed together
- For enum/interface renames: check all usages across main, preload, and renderer
