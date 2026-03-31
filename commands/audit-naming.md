---
description: Audit naming conventions across the project and suggest renames
category: audit
mutates: false
consumes: [source-code]
produces: [naming-report]
result_states: [clean, issues_found, execution_error]
next_on_result:
  clean: []
  issues_found: [implement, refactor-plan]
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

### Step 3: Delegate to Agent

Delegate to the **reviewer** agent focused on naming with full context from Steps 1-2.
The agent follows the naming conventions skill to audit each category:

1. Folder naming (kebab-case)
2. File naming (service, entity, component, hook, IPC, test conventions)
3. Enum naming (E prefix + PascalCase)
4. Interface & Type naming (I prefix + PascalCase, Props exception)
5. Class naming (PascalCase, role suffixes)
6. Function naming (A/HC/LC pattern, verb usage)
7. Variable naming (camelCase, boolean prefixes, collection plurals)
8. IPC channel naming (domain_actionCamelCase pattern)
9. React-specific naming (renderer only)
10. Database fields (snake_case for DB columns)
11. S-I-D principle check (no single-letter, no contractions, natural English)

Classify by file context (main process, preload, renderer, shared core, library, tests) to determine which rules apply.

### Step 4: Report

Generate a structured report based on the agent's findings:

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
