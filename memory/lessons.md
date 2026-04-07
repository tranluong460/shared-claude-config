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
- Action taken: removed unused workflow YAML + orchestrator components
- Follow-up needed: enforce `/generate-tests` after `/implement` — zero-test weeks must end

### 2026-04-07 — Config sync cascades hide behind "clean" audits

- Single-session experience: `/audit-config` reported clean after fixing 17 issues, but manual review found 7 more, including 1 critical semantic bug (`agents/architect.md` output template was single-file while `commands/refactor-plan.md` mandated folder output — full contradiction, passed audit).
- Root cause: static path-grep auditing cannot verify **semantic contracts** between commands and the agents they delegate to.
- Fix applied: new `skills/audit-config/` skill with `contract-checks.md` enumerating semantic invariants; `/audit-config` now must emit a **Coverage Report** listing invariants NOT checked.
- Rule of thumb: after any change to a command that delegates to an agent, manually cross-read the agent's `## Output Format` (or equivalent) section against the command's output rule.

### 2026-04-07 — Mega-commit pattern now 2-for-2; advisory rules insufficient

- Last week: 56/118/188-file commits. This week: 113-file working tree accumulating (+7486/-1112 lines).
- One advisory lesson (2026-03-31 "max 10-15 files/commit") did not change behavior.
- Fix applied: PreToolUse hook `check-commit-size.sh` blocks `git commit` with staged file count > 50 unless overridden with `SPLIT_OK=1` env or `[mega-ok]` tag in commit message.
- Threshold starts at 50 (nới cho working tree hiện tại), tighten to 20 after current mega-tree is committed.
- Precedent: "Hooks enforce what rules cannot" (2026-03-31) — this is the second application of that principle.

### 2026-04-07 — Zero-test week pattern is fixable when feature scope is clear

- First test-authoring week in project history: 8 test files for the new `humanize/` module, 1:1 file-to-test ratio.
- Success factor: humanize module is pure-function heavy (bezier, fitts-law, jitter, timing, keystroke-profile) — high testability by construction.
- Gap: stateful refactors in the same working tree (BrowserInitializer, ProcessLifecycleManager changes) still have **zero** new tests.
- Follow-up: consider PostToolUse hook on `.ts` file create in `src/` that warns if no matching `test/**/*.test.ts` appears within the same session.

### 2026-04-07 — Self-improvement loop now functional but still manual

- `/reflect` ran exactly 7 days after the last run — scheduling discipline is holding by a thread.
- Still human-triggered; no reminder. Risk: next week the user may forget and the loop breaks again.
- Fix applied: `hooks/post-compact.sh` now checks `lessons.md` mtime — if > 7 days old, inject a "TIME TO RUN /reflect 1 week" banner into the compaction context so Claude can surface it to the user.
