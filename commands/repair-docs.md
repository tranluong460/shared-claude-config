---
description: Fix documentation issues found by /audit-docs — attach dead docs, add missing references, fix broken pipelines
category: execute
mutates: true
consumes: [doc-audit-report]
produces: [fixed-claude-config]
next_on_success: [audit-docs]
---

You are executing the `/repair-docs` command.

## Input

Scope: $ARGUMENTS (default: fix all issues from latest `/audit-docs` run)

## Workflow

### Step 1: Load Skills

Read and apply:

- `.claude/skills/architecture-patterns/SKILL.md`
- `.claude/rules/no-unused-docs.md`

### Step 1b: Agent

Delegate to the `doc-auditor` agent for execution.

### Step 2: Assess Current State

Re-run the audit inventory (Steps 2-6 from `/audit-docs`) to get a fresh view of all issues:

1. Inventory all documents in `.claude/`
2. Map references between rules, skills, agents, commands, hooks
3. Classify each document (Active / Passive / Weakly Integrated / Dead / Orphaned)
4. Detect issues (dead docs, duplicates, missing integrations, inconsistencies)

### Step 3: Execute Fixes

For each issue found, apply the appropriate fix:

#### 3a. Dead Documents
- **Attach** to relevant command/agent OR **delete**
- Output: exact file path + exact change (line number, content to add)

#### 3b. Passive Critical Documents
- Promote to Active by injecting into relevant command or agent
- Output: which command/agent file, what line to add

#### 3c. Missing Integrations
- Add reference in the target command/agent
- Output: exact edit with old_string → new_string

#### 3d. Broken Pipelines
- Fix by creating missing agent or adding missing skill reference
- Output: file to create or edit

**Format for each fix:**
```
File: <path>
Action: <add/edit/delete>
Change: <exact content>
```

### Step 4: Verify

Re-run the audit inventory to confirm all issues are resolved. Report any remaining issues.

### Step 5: Report

```markdown
## Documentation Repair: .claude/

### Fixes Applied

| # | File | Action | Change |
|---|------|--------|--------|
| 1 | <path> | <add/edit/delete> | <description> |

### Remaining Issues

| Issue | Reason Not Fixed |
|-------|-----------------|
| <issue> | <reason — needs manual review / ambiguous / cross-cutting> |

### Verification

| Check | Before | After |
|-------|--------|-------|
| Dead documents | N | N |
| Missing integrations | N | N |
| Broken pipelines | N | N |
```

## Notes

- This command MUTATES files — review changes carefully before committing
- Run `/audit-docs` first to understand the scope of issues
- Run `/audit-docs` again after repair to verify all fixes
- Only fix clear-cut issues automatically; flag ambiguous cases for manual review
