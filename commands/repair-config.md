---
description: Fix .claude/ config issues found by /audit-config — attach dead docs, add missing references, fix broken pipelines
category: execute
mutates: true
consumes: [config-audit-report]
produces: [fixed-claude-config]
result_states: [success, validation_failed, blocked, execution_error]
next_on_result:
  success: [audit-config]
  validation_failed: [audit-config]
  blocked: []
  execution_error: [diagnose]
---

You are executing the `/repair-config` command.

## Input

Scope: $ARGUMENTS (default: fix all issues from latest `/audit-config` run)

## Workflow

### Step 1: Load Skills

Read and apply:

- `.claude/skills/architecture-patterns/SKILL.md`
- `.claude/skills/documentation-standards/SKILL.md`
- `.claude/rules/no-unused-docs.md`

### Step 2: Delegate to Agent

Delegate to the `doc-auditor` agent for execution. The agent handles:

1. Re-run inventory and classification (fresh view of all issues)
2. For dead documents: attach to relevant command/agent OR delete
3. For missing integrations: add reference in target command/agent
4. For broken pipelines: create missing agent or add missing skill reference
5. Output EXACT file paths and changes for each fix
6. Re-run audit to verify all issues resolved

### Step 3: Report

```markdown
## Config Repair: .claude/

### Fixes Applied

| #   | File   | Action            | Change        |
| --- | ------ | ----------------- | ------------- |
| 1   | <path> | <add/edit/delete> | <description> |

### Remaining Issues

| Issue   | Reason Not Fixed                  |
| ------- | --------------------------------- |
| <issue> | <needs manual review / ambiguous> |

### Verification

| Check                | Before | After |
| -------------------- | ------ | ----- |
| Dead documents       | N      | N     |
| Missing integrations | N      | N     |
| Broken pipelines     | N      | N     |
```

## Notes

- This command MUTATES files — review changes carefully before committing
- Run `/audit-config` first to understand the scope of issues
- Run `/audit-config` again after repair to verify all fixes
- Only fix clear-cut issues automatically; flag ambiguous cases for manual review
