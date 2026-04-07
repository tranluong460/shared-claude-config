---
name: reflection
description: Session analysis and self-improvement — review recent work patterns, identify recurring mistakes, and suggest config improvements. Self-sufficient — invoked directly by /reflect, no subagent needed.
layer: workflow
---

# Reflection & Self-Improvement

## Purpose

Analyze recent sessions to identify patterns, recurring mistakes, and opportunities to improve the `.claude` configuration. This closes the feedback loop: work → reflect → improve config → better work.

> **This skill replaces the former `reflection-analyzer` agent (Phase 4 consolidation).** It is invoked directly by `/reflect` — no isolated agent context needed because the analysis is read-only and benefits from the main session's existing context.

## Core Discipline

- **Focus on patterns, not individual incidents.** A one-off issue is noise; a recurring issue is signal.
- **Suggest config changes that prevent future mistakes.** "Add rule X to file Y" beats "should improve".
- **Recurring (2+ times) → propose change. One-off → note and move on.**
- **Reinforce positives.** Don't just focus on negatives.

## What to Analyze

### 1. Recent Git History

```
git log --oneline -20                    # recent commits
git log --all --oneline --since="1 week ago"  # weekly scope
```

Look for:

- Reverted commits (indicates mistakes)
- Fixup commits (indicates missed issues on first pass)
- Commit message patterns (consistent? descriptive?)

### 2. Code Patterns

```
# Find recently modified files
git diff --name-only HEAD~20

# Check for recurring issues
Grep: "any" in recently changed .ts files
Grep: "console.log" in src/
Grep: "TODO" added recently
```

Look for:

- Same type of fix applied repeatedly → needs a rule
- Patterns that violate existing rules → rules not effective enough
- New patterns emerging → document them

### 3. Session Effectiveness

Evaluate against these questions:

- Were tasks completed in one session or did they span multiple?
- How many corrections did the user make?
- Were there any `/clear` or `/compact` events? (sign of context exhaustion)
- Did subagents help or add overhead?

## Improvement Categories

### Rules Improvements

| Signal                                 | Action                                           |
| -------------------------------------- | ------------------------------------------------ |
| Same mistake 2+ times                  | Add or strengthen a rule                         |
| Rule exists but was ignored            | Add emphasis (IMPORTANT/MUST) or convert to hook |
| Rule too broad, causes false positives | Add exceptions or narrow path scope              |
| New code pattern not covered           | Create new rule                                  |

### Skill Improvements

| Signal                                             | Action                        |
| -------------------------------------------------- | ----------------------------- |
| Agent produced incomplete output                   | Add missing section to skill  |
| Agent asked user for info the skill should provide | Add that knowledge to skill   |
| Skill content contradicts codebase                 | Update skill to match reality |

### Hook Improvements

| Signal                              | Action                           |
| ----------------------------------- | -------------------------------- |
| Convention violated despite rule    | Promote rule to PreToolUse hook  |
| Manual step always forgotten        | Automate with PostToolUse hook   |
| Repeated context loss after compact | Improve PostCompact hook content |

### CLAUDE.md Improvements

| Signal                                   | Action                       |
| ---------------------------------------- | ---------------------------- |
| Claude keeps asking for build commands   | Add to CLAUDE.md             |
| Wrong assumption about project structure | Add clarification            |
| Content too long (>200 lines)            | Move details to rules/skills |

## Output Format

```markdown
## Reflection: <date range>

### Session Summary

- Commits analyzed: N
- Files changed: N
- Patterns detected: N

### What Went Well

- <positive patterns to reinforce>

### Recurring Issues

| #   | Issue | Frequency | Root Cause | Suggested Fix |
| --- | ----- | --------- | ---------- | ------------- |
| 1   | ...   | N times   | ...        | ...           |

### Config Improvements

| Priority | Type                      | Change | Why |
| -------- | ------------------------- | ------ | --- |
| High     | rule/skill/hook/CLAUDE.md | ...    | ... |

### Lessons Captured

- <new lessons to add to .claude/memory/lessons.md>
```

## Quick Reference: Fix Type Mapping

| Type | How to fix |
|---|---|
| Missing convention | Add rule in `.claude/rules/` |
| Rule ignored | Strengthen wording or promote to hook |
| Missing knowledge | Add to relevant skill |
| Build/test gap | Add to project CLAUDE.md or implementation rule |
| Repeated manual step | Automate with hook |

## Direct Invocation Process

When `/reflect` runs:

1. Parse scope from `$ARGUMENTS` (default: 1 week)
2. Run git evidence-gathering commands above
3. Spot-check recently changed files for known violations
4. Categorize findings: recurring vs one-off vs positive
5. Propose specific config changes for recurring patterns only
6. Append new lessons to `.claude/memory/lessons.md` (consolidate, don't duplicate)
7. Output the report
