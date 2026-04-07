# Semantic Contract Checks

> Invariants that `/audit config` MUST verify beyond static path-grep. Each invariant lists: what to check, how to check, and a real precedent (the bug this check would have caught).

## Invariant 1 — Command ↔ Agent output format contract

**Rule**: If command X delegates to agent Y, then Y's `## Output Format` (or `## Output Formats`, or `### {OutputType}`) section MUST describe the same output structure that X documents.

**How to check**:
1. For every `.claude/commands/*.md`, find the "Delegate to Agent" / "Delegate to the `<agent>`" line.
2. Read the agent file's `## Output Format` section.
3. Compare the two: same file type (single file vs folder), same structure, same naming.
4. Flag any mismatch.

**Precedent** (2026-04-07): `commands/refactor-plan.md` Step 4 said "Write the plan as a folder under `docs/plans/YYYYMMDD-{name}/`". `agents/architect.md` "Refactoring Plan" section showed a single-document template with `## Problem / ## Target State / ## Phases`. Audit passed because all paths were syntactically valid. User caught it on manual review.

## Invariant 2 — Command ↔ Skill template alignment

**Rule**: If command X loads skill S and the command's docs mention a doc type T, then S MUST contain a template for T.

**How to check**:
1. For every command, extract the "Load Skills" list and the doc-type table (if any).
2. For each doc type in the command table, grep the loaded skills for a matching `### N. {DocType}` section.
3. Flag missing templates.

**Precedent**: Before this skill, `/generate-docs` listed `onboarding` and `user-guide` as required tracks, but `documentation-standards/SKILL.md` had no Section 8/9 templates. Had to retro-fit in the same session.

## Invariant 3 — Rule path ↔ actual folder convention

**Rule**: If `rules/documentation.md` names a canonical folder (e.g. `docs/fix/`, `docs/onboarding/`, `docs/plans/YYYYMMDD-{name}/`), then:
- No file in `.claude/` may reference the OLD path for the same concept (e.g. `docs/troubleshooting/`, `docs/plans/YYYYMMDD-{name}.md`).
- The canonical folder must actually exist in the repo OR the rule must mark it "bootstrap required".

**How to check**:
1. Extract every folder path from `rules/documentation.md`.
2. For each path, also grep for the known legacy alias (`troubleshooting` for `fix`, flat `.md` for plan folders).
3. Flag any legacy-alias hit outside of explicit "do NOT create" warnings.
4. For each canonical path, check `docs/` for existence; if missing, check rule for bootstrap flag.

**Precedent** (2026-04-07): `docs/fix/` replaced `docs/troubleshooting/` across 4 files in Cycle 2, but 6 more files still mentioned "troubleshooting" in comments/labels. Audit caught the broken paths in 2 files, user had to catch the stale wording in 6 more.

## Invariant 4 — Hook matcher regex ↔ command keyword coverage

**Rule**: If a command's description mentions a use case (e.g. "onboarding", "user-guide", "plan folder"), then `hooks/suggest-commands.sh` MUST have a regex that matches the corresponding user prompt.

**How to check**:
1. Extract every command's `description:` frontmatter + key example invocations.
2. Extract every regex in `hooks/suggest-commands.sh`.
3. For each command use case, check if any regex covers the relevant keywords.
4. Flag gaps.

**Precedent** (2026-04-07): `/generate-docs onboarding` and `/generate-docs user-guide` were required tracks, but `suggest-commands.sh` regex at L44 only matched `doc|readme|adr|changelog|document` — users typing "set up onboarding for new devs" never got the suggestion. User caught it on manual audit.

## Invariant 5 — Agent frontmatter `skills:` ↔ actual skill folders

**Rule**: Every name in an agent's `skills:` frontmatter list MUST correspond to an existing `.claude/skills/{name}/SKILL.md`.

**How to check**:
1. For every `.claude/agents/*.md`, parse the `skills:` frontmatter list.
2. For each name, check `.claude/skills/{name}/SKILL.md` exists.
3. Flag missing skills.

**Precedent**: None yet — this is preventive. Easy to break when renaming skills.

## Invariant 6 — Command `next_on_result` ↔ target command existence

**Rule**: Every command name in a `next_on_result` frontmatter map MUST correspond to an existing `.claude/commands/{name}.md`.

**How to check**:
1. For every command, parse `next_on_result:` frontmatter.
2. For each target, check file existence.
3. Flag broken chain links.

**Precedent**: None yet. Preventive against future command renames.

## Invariant 7 — `log-command.sh` discovers commands dynamically (DRY)

**Rule**: `hooks/log-command.sh` MUST NOT contain a hardcoded `KNOWN_COMMANDS=` list. It must discover commands dynamically by checking for `commands/$CMD_NAME.md` existence.

**How to check**:
1. `grep -n 'KNOWN_COMMANDS=' .claude/hooks/log-command.sh` → must return 0 matches OR a comment-only line.
2. Verify the script reads `.claude/commands/` to test command existence.
3. Flag any reintroduction of a hardcoded list.

**Precedent** (2026-04-07): Original script had a hardcoded `KNOWN_COMMANDS="audit-code audit-project ..."` list with 13 names. After consolidation refactor (13 → 7), the list would have gone stale immediately. Replaced with dynamic file existence check. This invariant prevents regression.

## Invariant 8 — Agent `## Output Format` section presence

**Rule**: Every agent that is delegated to by a command MUST have a `## Output Format` or `## Output Formats` section. Agents without output formats cannot be contract-checked.

**How to check**:
1. For each command, extract the delegated agent name.
2. For each unique agent, grep for `^## Output Format` heading.
3. Flag missing sections.

**Precedent**: `impact-analyst.md` had a vague "Always produce a structured Impact Analysis Report following the template in the impact-analysis skill" instead of an explicit Output Format section. Hard to contract-check.

## How to use this file from `/audit config`

1. The command loads this skill via `Read: .claude/skills/audit config/contract-checks.md`.
2. For each invariant, run the check and emit a row in the "Semantic Contract Check" section of the audit report.
3. In the "Audit Coverage Report" section, list which invariants were checked and which were skipped (with reason).
4. Invariants that cannot be mechanically verified (require semantic judgment) should be explicitly listed as "spot-read required" rather than silently skipped.
