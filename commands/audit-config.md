---
description: Audit .claude/ config consistency — detect unused, duplicated, or weakly integrated components (read-only analysis)
category: audit
mutates: false
consumes: [claude-config]
produces: [config-audit-report]
result_states: [clean, issues_found, execution_error]
next_on_result:
  clean: []
  issues_found: [repair-config]
  execution_error: [diagnose]
---

You are executing the `/audit-config` command.

## Input

Scope: $ARGUMENTS (default: entire `.claude/` directory)

## Workflow

### Step 1: Load Skills

Read and apply:

- `.claude/skills/architecture-patterns/SKILL.md`
- `.claude/skills/documentation-standards/SKILL.md`
- `.claude/rules/no-unused-docs.md`

### Step 2: Delegate to Agent

Delegate to the `doc-auditor` agent for execution. The agent handles:

1. Inventory all documents (rules, commands, agents, skills, hooks, settings)
2. Map references between components (who loads/references whom)
3. Classify each document (Active / Passive / Dead)
4. Detect issues (dead docs, duplicate content, missing integrations, inconsistencies)
5. Verify pipeline integrity: User → Hook → Command → Agent → Skill/Rule → Output

### Step 3: Report

```markdown
## Config Audit: .claude/

### Inventory Summary

| Type     | Count | Active | Passive | Dead |
| -------- | ----- | ------ | ------- | ---- |
| Rules    | N     | N      | N       | N    |
| Commands | N     | N      | -       | -    |
| Agents   | N     | N      | -       | N    |
| Skills   | N     | N      | -       | N    |
| Hooks    | N     | N      | -       | N    |

### Issues Found

| File | Classification | Issue | Recommendation   |
| ---- | -------------- | ----- | ---------------- |
| ...  | Dead/Passive   | ...   | Attach or delete |

### Pipeline Verification

| Command | Hook Suggested | Agent | Skills Loaded | Status    |
| ------- | -------------- | ----- | ------------- | --------- |
| ...     | Yes/No         | ...   | N             | OK/Broken |

### Recommendations

| Priority | Action | Files Affected |
| -------- | ------ | -------------- |
| 1        | ...    | ...            |
```

## Notes

> To fix issues found by this audit, run `/repair-config`.

- Auto-injected rules (with `paths:` frontmatter) are passive by design — acceptable
- Rules are concise enforcement, skills are detailed reference — conceptual overlap is normal
- Only flag TRUE duplication (copy-pasted content), not conceptual overlap
- Focus on actionable findings: dead docs to remove, missing references to add
