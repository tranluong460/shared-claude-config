---
description: Analyze recent sessions — identify patterns, recurring mistakes, and suggest config improvements
category: improve
mutates: false
consumes: [git-history, command-history, lessons]
produces: [reflection-report, config-suggestions]
result_states: [insights_found, no_patterns, execution_error]
next_on_result:
  insights_found: []
  no_patterns: []
  execution_error: []
---

You are executing the `/reflect` command.

## Input

Scope: $ARGUMENTS (default: "1 week", accepts: "today", "3 days", "1 week", "1 month")

## Workflow

### Step 1: Load Skill

Read and apply:

- `.claude/skills/reflection/SKILL.md` (self-sufficient — contains the full reflection methodology, no agent delegation needed)
- `.claude/skills/coding-standards/SKILL.md`

> The former `reflection-analyzer` agent was migrated into the `reflection` skill in Phase 4 consolidation. Reflection is read-only analysis that benefits from the main session's context — no isolated agent context is required.

### Step 2: Gather Evidence

1. **Git history** within scope:

```bash
git log --oneline --since="<scope>"
git log --all --diff-filter=M --since="<scope>" --name-only
```

2. **Reverts and fixups** (signs of mistakes):

```bash
git log --oneline --since="<scope>" --grep="revert\|fixup\|fix:\|oops\|typo"
```

3. **Current rule violations** — spot check recently changed files:

```bash
# Get recently changed .ts files
git diff --name-only HEAD~10 -- '*.ts' '*.tsx'
```

Then check each for: `any` types, `console.log`, empty catch, missing return types, functions >50 lines.

4. **Command history** (if exists):

```
Read .claude/memory/command-history.jsonl
```

Analyze: which commands ran most, which result states occurred, any patterns of repeated failures or retries.

5. **Previous lessons** (if exists):

```
Read .claude/memory/lessons.md
```

Check: are previous lessons being followed? Any recurring issues that were already identified?

### Step 3: Analyze Patterns

For each finding, categorize:

- **Recurring** (2+ times) → needs config change
- **One-off** → note but don't over-react
- **Positive** → reinforce (don't just focus on negatives)

### Step 4: Propose Config Improvements

For each recurring issue, propose a specific change:

| Type                 | How to fix                              |
| -------------------- | --------------------------------------- |
| Missing convention   | Add rule in `.claude/rules/`            |
| Rule ignored         | Strengthen wording or promote to hook   |
| Missing knowledge    | Add to relevant skill                   |
| Build/test gap       | Add to CLAUDE.md or implementation rule |
| Repeated manual step | Automate with hook                      |

### Step 5: Report

Present findings using the output format from the reflection skill.

### Step 6: Apply (If Approved)

If the user approves changes:

1. Update the relevant config files
2. If new lessons found → append to `.claude/memory/lessons.md` using format: `### YYYY-MM-DD — <topic>` followed by bullet points
3. Verify no contradictions introduced between rules/skills

## Notes

- This command is meant to be run weekly as a habit
- Focus on actionable improvements, not just observations
- Don't propose changes for one-off issues — only recurring patterns
- Keep proposed changes minimal and focused
