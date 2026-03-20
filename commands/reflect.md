---
description: Analyze recent sessions — identify patterns, recurring mistakes, and suggest config improvements
---

You are executing the `/reflect` command.

## Input

Scope: $ARGUMENTS (default: "1 week", accepts: "today", "3 days", "1 week", "1 month")

## Workflow

### Step 1: Load Skills

Read and apply:

- `.claude/skills/reflection/SKILL.md`
- `.claude/skills/coding-standards/SKILL.md`

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

4. **Tasks and lessons** (if they exist):

```
Read tasks/lessons.md (if exists)
Read tasks/todo.md (if exists)
```

### Step 3: Analyze Patterns

For each finding, categorize:

- **Recurring** (2+ times) → needs config change
- **One-off** → note but don't over-react
- **Positive** → reinforce (don't just focus on negatives)

### Step 4: Propose Config Improvements

For each recurring issue, propose a specific change:

| Type | How to fix |
| ---- | ---------- |
| Missing convention | Add rule in `.claude/rules/` |
| Rule ignored | Strengthen wording or promote to hook |
| Missing knowledge | Add to relevant skill |
| Build/test gap | Add to CLAUDE.md or implementation rule |
| Repeated manual step | Automate with hook |

### Step 5: Report

Present findings using the output format from the reflection skill.

### Step 6: Apply (If Approved)

If the user approves changes:

1. Update the relevant config files
2. If new lessons found → append to `tasks/lessons.md`
3. Verify no contradictions introduced between rules/skills

## Notes

- This command is meant to be run weekly as a habit
- Focus on actionable improvements, not just observations
- Don't propose changes for one-off issues — only recurring patterns
- Keep proposed changes minimal and focused
