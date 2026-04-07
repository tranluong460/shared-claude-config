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
- `.claude/skills/audit-config/SKILL.md` — **required** — header warning + audit levels
- `.claude/skills/audit-config/contract-checks.md` — **required** — semantic invariants enumerated
- `.claude/rules/no-unused-docs.md`
- `.claude/rules/documentation.md` — Command ↔ Agent output contract invariant

### Step 2: Delegate to Agent

Delegate to the `doc-auditor` agent for execution. The agent handles **three audit levels** (cumulative — L2 requires L1 pass, L3 requires L2 pass):

**L1 — Static checks** (cheap, always run):
1. Inventory all documents (rules, commands, agents, skills, hooks, settings)
2. Map references between components (who loads/references whom)
3. Classify each document (Active / Passive / Dead)
4. Detect issues (dead docs, duplicate content, missing integrations, inconsistencies)
5. Verify pipeline integrity: User → Hook → Command → Agent → Skill/Rule → Output

**L2 — Semantic contract checks** (required — per `skills/audit-config/contract-checks.md`):
1. **Invariant 1** — Command ↔ Agent output format contract
2. **Invariant 2** — Command ↔ Skill template alignment
3. **Invariant 3** — Rule path ↔ actual folder convention (check legacy aliases)
4. **Invariant 4** — Hook matcher regex ↔ command keyword coverage
5. **Invariant 5** — Agent `skills:` frontmatter ↔ skill folder existence
6. **Invariant 6** — Command `next_on_result` ↔ target command existence
7. **Invariant 7** — `KNOWN_COMMANDS` in `log-command.sh` ↔ actual commands (exact diff, not count)
8. **Invariant 8** — Agent `## Output Format` section presence

**L3 — Spot-read** (on-demand, after recent sync cycles):
- For every command file changed in the last commit, manually read the output-writing step and cross-reference the delegated agent's `## Output Format` section. Report which files were spot-read.

### Step 3: Report

Every audit run MUST include ALL sections below. Missing sections = incomplete audit, must NOT be reported as clean.

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

### Issues Found (L1 static)

| File | Classification | Issue | Recommendation   |
| ---- | -------------- | ----- | ---------------- |
| ...  | Dead/Passive   | ...   | Attach or delete |

### Pipeline Verification

| Command | Hook Suggested | Agent | Skills Loaded | Status    |
| ------- | -------------- | ----- | ------------- | --------- |
| ...     | Yes/No         | ...   | N             | OK/Broken |

### Semantic Contract Check (L2)

| # | Invariant | Result | Details |
| - | --------- | ------ | ------- |
| 1 | Command ↔ Agent output format | ✓/✗ | <which pairs mismatched, if any> |
| 2 | Command ↔ Skill template      | ✓/✗ | ... |
| 3 | Rule path ↔ folder convention | ✓/✗ | <any legacy-alias hits> |
| 4 | Hook regex ↔ command keywords | ✓/✗ | ... |
| 5 | Agent skills: ↔ skill folders | ✓/✗ | ... |
| 6 | next_on_result ↔ command files | ✓/✗ | ... |
| 7 | KNOWN_COMMANDS diff           | ✓/✗ | <exact +/- list> |
| 8 | Agent Output Format presence  | ✓/✗ | ... |

### Audit Coverage Report (REQUIRED)

- **Files scanned**: <count> under `.claude/`
- **Invariants checked**: <list by number, e.g. "L1 + Invariants 1,2,3,4,5,6,7,8">
- **Invariants NOT checked**: <list with reason, e.g. "L3 spot-read skipped — no command files changed in last commit">
- **Spot-reads performed**: <file paths manually read, or "none">
- **Confidence**: High / Medium / Low — justify

### Recommendations

| Priority | Action | Files Affected |
| -------- | ------ | -------------- |
| 1        | ...    | ...            |
```

## Notes

> To fix issues found by this audit, run `/repair-config`.

- **Clean verdict requires ALL sections present and L1 + L2 + L3 (where applicable) passing.**
- Auto-injected rules (with `paths:` frontmatter) are passive by design — acceptable
- Rules are concise enforcement, skills are detailed reference — conceptual overlap is normal
- Only flag TRUE duplication (copy-pasted content), not conceptual overlap
- Focus on actionable findings: dead docs to remove, missing references to add
- **Clean is necessary but NOT sufficient** (see `skills/audit-config/SKILL.md` header warning). After any sync cycle, L3 spot-read is mandatory — list which files were manually read in the Coverage Report.
