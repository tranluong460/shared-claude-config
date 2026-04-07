# Lessons Learned

> Accumulated insights from `/reflect` sessions. Append new lessons at the bottom.
> Format: `### YYYY-MM-DD — <topic>` followed by bullet points.
> Audit & cleanup happens during `/reflect` runs — entries already enforced by hooks may be marked `[ENFORCED]` and kept for context.

### 2026-03-31 — Code quality hooks enforce what rules cannot [PRINCIPLE]

- Advisory rules in `.claude/rules/` are followed ~80% of the time.
- Hooks (PostToolUse) enforce 100% — they are law, not guidance.
- Promote critical rules to hooks when compliance must be 100%.
- Applications: `check-code-quality.sh` (any/console.log/limits), `check-commit-size.sh` (mega-commits), `tsc-check.sh` (type errors).

### 2026-03-31 — Self-improvement loop must point at the right path

- CLAUDE.md previously pointed to `tasks/lessons.md` instead of `.claude/memory/lessons.md` → file stayed empty for entire project lifetime.
- Fix: CLAUDE.md now points to correct path; `post-compact.sh` injects reminder if mtime > 7 days.
- Run `/reflect 1 week` weekly.

### 2026-04-07 — Config sync cascades hide behind "clean" audits

- `/audit-config` reported clean after 17 fixes, but manual review found 7 more, including 1 critical semantic bug (`agents/architect.md` output template was single-file while `commands/refactor-plan.md` mandated folder output — full contradiction, passed audit).
- Root cause: static path-grep auditing cannot verify **semantic contracts** between commands and the agents they delegate to.
- Fix: new `skills/audit-config/` skill with `contract-checks.md` enumerating semantic invariants; `/audit-config` now must emit a **Coverage Report** listing invariants NOT checked.
- Rule of thumb: after any change to a command that delegates to an agent, manually cross-read the agent's `## Output Format` (or equivalent) section against the command's output rule.

### 2026-04-07 — Mega-commit pattern: advisory rules insufficient [ENFORCED by check-commit-size.sh]

- Two consecutive weeks: 56/118/188-file commits, then 113-file working tree (+7486/-1112).
- One advisory lesson did not change behavior — required a hook.
- Fix: PreToolUse hook `check-commit-size.sh` blocks `git commit` with > 50 staged files unless `SPLIT_OK=1` env or `[mega-ok]` tag in commit message. Threshold tightens to 20 after current mega-tree clears.
- This is the second application of the "Hooks enforce what rules cannot" principle.

### 2026-04-07 — Zero-test week pattern is fixable when feature scope is clear

- First test-authoring week in project history: 8 test files for the new `humanize/` module, 1:1 file-to-test ratio.
- Success factor: humanize module is pure-function heavy (bezier, fitts-law, jitter, timing, keystroke-profile) — high testability by construction.
- Gap: stateful refactors in the same working tree (BrowserInitializer, ProcessLifecycleManager) still have **zero** new tests.
- Follow-up candidate: PostToolUse hook on `.ts` create in `src/` warning if no matching `test/**/*.test.ts` appears within session.

### 2026-04-07 — Optimization refactor: hooks > rules > skills > agents > commands

- Research validated community 2026 consensus: setup is in top 5% complexity for solo dev project.
- Action: consolidated commands 13 → 7, agents 10 → 6, added tsc-check hook, created project-level CLAUDE.md, slimmed project-context skill.
- Estimated savings: 20-40% token/session via removed scan overhead and on-demand loading.
- Principle reinforced: each layer added has diminishing returns; merge overlap aggressively.
