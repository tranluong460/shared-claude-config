---
description: Audit documentation consistency — detect unused, duplicated, or weakly integrated docs in .claude/
---

You are executing the `/audit-docs` command.

## Input

Scope: $ARGUMENTS (default: entire `.claude/` directory)

## Workflow

### Step 1: Load Skills

Read and apply:

- `.claude/skills/architecture-patterns/SKILL.md`
- `.claude/rules/no-unused-docs.md`

### Step 1b: Agent

Delegate to the `doc-auditor` agent for execution.

### Step 2: Inventory All Documents

Read the full `.claude/` directory structure and categorize every document:

```
# All rule files
.claude/rules/*.md

# All command files
.claude/commands/*.md

# All agent files
.claude/agents/*.md

# All skill files
.claude/skills/*/SKILL.md

# All hook files
.claude/hooks/*.sh

# Settings
.claude/settings.local.json
```

Build an inventory table:

```markdown
| File | Type | Has Frontmatter | Path Scope |
| ---- | ---- | --------------- | ---------- |
| ...  | rule/command/agent/skill/hook | Yes/No | paths value or N/A |
```

### Step 3: Map References

For each document, determine all references:

#### 3a. Rule References

For each file in `rules/`:

1. **Frontmatter check**: Does it have `paths:` frontmatter? (If yes, it auto-injects when editing matching files)
2. **Command references**: Grep for the rule filename across `commands/*.md`
3. **Agent references**: Grep for the rule filename across `agents/*.md`
4. **Skill references**: Grep for the rule filename across `skills/*/SKILL.md`
5. **Hook references**: Grep for the rule filename across `hooks/*.sh` and `settings.local.json`

#### 3b. Skill References

For each file in `skills/*/SKILL.md`:

1. **Command load**: Grep for the skill directory name in `commands/*.md` (look for `skills/{name}/SKILL.md`)
2. **Agent load**: Check the `skills:` frontmatter in `agents/*.md`

#### 3c. Agent References

For each file in `agents/`:

1. **Command usage**: Grep for the agent name in `commands/*.md`

#### 3d. Command References

For each file in `commands/`:

1. **Hook suggestion**: Check `hooks/suggest-commands.sh` for matching keyword patterns

### Step 4: Classify Each Document

Based on the reference mapping, classify:

| Classification | Criteria |
| -------------- | -------- |
| **Active** | Referenced by at least one command/agent AND has path-scoped frontmatter (for rules) |
| **Passive** | Has `paths:` frontmatter (auto-injects) but NOT explicitly referenced by any command or agent |
| **Weakly Integrated** | Referenced by only 1 command/agent, or has no frontmatter but is referenced |
| **Dead** | Not referenced anywhere AND has no `paths:` frontmatter |
| **Orphaned** | Claims to be referenced (e.g., "agents reference here") but actually is not |

### Step 5: Detect Issues

#### 5a. Dead Documents

Files that exist but are never loaded, referenced, or auto-injected:

- No `paths:` frontmatter (rules)
- No command/agent loads them
- No hook triggers them

#### 5b. Duplicate Content

Cross-compare documents for overlapping content:

- Same concept explained in both a rule and a skill
- Same checklist duplicated across multiple commands
- Same table/reference duplicated in rule AND skill

Note: Rules are meant to be concise enforcement, skills are detailed reference. Some overlap is by design. Only flag when the SAME content is copy-pasted.

#### 5c. Missing Integrations

Detect cases where a document SHOULD be loaded but is not:

| Signal | Missing Integration |
| ------ | ------------------- |
| Rule covers topic X, command handles topic X | Command should reference the rule |
| Skill exists for domain Y, agent works in domain Y | Agent should list the skill |
| Command exists but `suggest-commands.sh` has no keyword match | Hook should suggest the command |

#### 5d. Inconsistencies

- Rule says "do not duplicate" but content IS duplicated elsewhere
- Agent `skills:` frontmatter lists a skill that doesn't exist
- Command references an agent that doesn't exist
- Frontmatter `paths:` pattern that matches no files in the project

### Step 6: Report

```markdown
## Documentation Audit: .claude/

### Inventory Summary

| Type     | Count | Active | Passive | Weak | Dead |
| -------- | ----- | ------ | ------- | ---- | ---- |
| Rules    | N     | N      | N       | N    | N    |
| Commands | N     | N      | -       | -    | -    |
| Agents   | N     | N      | -       | -    | N    |
| Skills   | N     | N      | -       | -    | N    |
| Hooks    | N     | N      | -       | -    | N    |

### Reference Map

#### Rules

| Rule | Frontmatter | Commands | Agents | Skills | Classification |
| ---- | ----------- | -------- | ------ | ------ | -------------- |
| `code-quality.md` | `src/**` | - | - | coding-standards, naming-conventions | Passive |
| `error-patterns.md` | - | diagnose | debugger | - | Active |
| ... | ... | ... | ... | ... | ... |

#### Skills

| Skill | Loaded by Commands | Loaded by Agents | Classification |
| ----- | ------------------ | ---------------- | -------------- |
| coding-standards | audit-project, ... | architect, ... | Active |
| ... | ... | ... | ... |

#### Agents

| Agent | Used by Commands | Skills Loaded | Classification |
| ----- | ---------------- | ------------- | -------------- |
| architect | audit-project, refactor-plan | 4 skills | Active |
| ... | ... | ... | ... |

#### Commands

| Command | Uses Agent | Loads Skills | Hook Suggested | Classification |
| ------- | ---------- | ------------ | -------------- | -------------- |
| audit-naming | code-reviewer | 1 | Yes | Active |
| ... | ... | ... | ... | ... |

### Issues Found

#### Dead Documents

| File | Reason | Recommendation |
| ---- | ------ | -------------- |
| `rules/xxx.md` | No frontmatter, no references | Add paths: frontmatter OR reference from relevant command OR delete |

#### Duplicate Content

| Content | Found In | Recommendation |
| ------- | -------- | -------------- |
| "..." | rule X, skill Y | Keep in skill, reference from rule |

#### Missing Integrations

| Document | Should Be Referenced By | Why |
| -------- | ----------------------- | --- |
| `rules/xxx.md` | `commands/yyy.md` | Command handles the same domain |

#### Inconsistencies

| Issue | Location | Fix |
| ----- | -------- | --- |
| Claims "agents reference here" but none do | `rules/xxx.md` | Remove claim or add reference |

### Recommendations

| Priority | Action | Files Affected |
| -------- | ------ | -------------- |
| 1 | <specific action> | <specific files> |
| 2 | <specific action> | <specific files> |
```

### Step 7: Enforce (MANDATORY)

After producing the report, execute fixes for all critical issues:

#### 7a. Dead Documents
- **Attach** to relevant command/agent OR **delete**
- Output: exact file path + exact change (line number, content to add)

#### 7b. Passive Critical Documents
- Promote to Active by injecting into relevant command or agent
- Output: which command/agent file, what line to add

#### 7c. Missing Integrations
- Add reference in the target command/agent
- Output: exact edit with old_string → new_string

#### 7d. Broken Pipelines
- Fix by creating missing agent or adding missing skill reference
- Output: file to create or edit

**Format for each fix:**
```
File: <path>
Action: <add/edit/delete>
Change: <exact content>
```

Do NOT just report issues — fix them or provide copy-paste-ready fixes.

## Notes

- Auto-injected rules (with `paths:` frontmatter) are passive by design -- this is acceptable
- Rules are meant to be concise, skills are meant to be detailed -- some conceptual overlap is normal
- Only flag TRUE duplication where content is copy-pasted, not conceptual overlap
- A rule being "passive" is not necessarily a problem -- path-scoped auto-injection is a valid pattern
- Focus on actionable findings: dead docs to remove, missing references to add, hooks to update
