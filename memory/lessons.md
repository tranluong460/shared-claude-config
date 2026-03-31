# Lessons Learned

> Accumulated insights from `/reflect` sessions. Append new lessons at the bottom.
> Format: `### YYYY-MM-DD — <topic>` followed by bullet points.

### 2026-03-31 — Zero-test week pattern

- 18 commits, 81 .ts/.tsx files changed, 0 test files touched in 1 week
- `/generate-tests` was never invoked despite heavy refactoring
- After `/implement` on logic changes, always run `/generate-tests` for changed modules
- Biggest production risk: no safety net for regressions

### 2026-03-31 — Mega-commit pattern

- 3 commits bundled 56, 118, and 188 files each into single commits
- Hard to review, impossible to git bisect, risky to revert
- Split large refactors into max 10-15 files per commit
- Commit incrementally: one logical change at a time

### 2026-03-31 — Self-improvement loop was broken

- CLAUDE.md pointed to `tasks/lessons.md` instead of `.claude/memory/lessons.md`
- lessons.md stayed empty for entire project lifetime
- Fixed: CLAUDE.md now points to correct path
- Run `/reflect 1 week` weekly to keep this file alive

### 2026-03-31 — Code quality hooks enforce what rules cannot

- Advisory rules in `.claude/rules/` are followed ~80% of the time
- Hooks (PostToolUse) enforce 100% — they are law, not guidance
- Created `check-code-quality.sh` hook: checks `any` type, `console.log`, 50-line, 300-line limits
- Promote critical rules to hooks when compliance must be 100%

### 2026-03-31 — Command usage is healthy but unbalanced

- `/implement` (9x), `/refactor-plan` (3x), audits (5x) — good adoption
- `/generate-tests` (0x), `/parallel-review` (1x) — testing and review underused
- Workflow YAML + orchestrator never executed — monitor if needed or simplify
