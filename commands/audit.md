---
description: Unified audit command — code review, config consistency, project architecture, repair, or diagnose. Routes via $ARGUMENTS subcommand.
category: audit
mutates: false
consumes: [source-code, claude-config, package-json, error-description]
produces: [audit-report]
result_states: [clean, issues_found, root_cause_found, insufficient_evidence, execution_error]
next_on_result:
  clean: [plan, implement]
  issues_found: [plan, implement]
  root_cause_found: [test, implement]
  insufficient_evidence: [audit]
  execution_error: []
---

You are executing the `/audit` command. This is a **unified audit dispatcher** consolidating five legacy commands (audit-code, audit-config, audit-project, repair-config, diagnose) under one entry point.

## Input

```
/audit <subcommand> [target...]
```

| Subcommand | Behavior | Delegates to | Mutates |
|---|---|---|---|
| `code [target]` | Code quality, naming, anti-patterns review (default if no subcommand) | reviewer | no |
| `code naming <scope>` | Deep naming-only audit | reviewer | no |
| `config [scope]` | `.claude/` consistency check (L1+L2+L3) | doc-auditor (audit mode) | no |
| `project [target]` | Full architecture audit | architect | no |
| `repair [scope]` | Fix issues found by `/audit config` | doc-auditor (repair mode) | **yes** |
| `diagnose <problem> [path]` | Root-cause investigation for bugs/errors | debugger | no |

If `$ARGUMENTS` is empty or starts with a path/file, default to `code`.

## Workflow

### Step 1: Parse subcommand

Parse the first token of `$ARGUMENTS`:
- Recognized subcommands: `code`, `config`, `project`, `repair`, `diagnose`
- Anything else → treat full `$ARGUMENTS` as `code <args>`
- Strip the subcommand from args; remainder is the target/scope/problem.

### Step 2: Route

Dispatch to the appropriate playbook below. Each playbook reuses the original command's logic unchanged.

---

## Playbook: `code` — Code review

**Skills**: `coding-standards`, `naming-conventions`, `architecture-patterns`
**Rules auto-injected**: `code-quality`, `error-patterns`, `react`, `electron`, `ipc` (per file paths)
**Agent**: `reviewer` (standard mode)

1. Detect project type (`.claude/rules/project-detection.md`).
2. Discover scope:
   - Specific target → `<target>/**/*.{ts,tsx}`
   - `recent` or no target → `git diff --name-only HEAD~5`
   - PR review → `git diff --name-only main...HEAD`
3. Delegate to **reviewer** agent. If args start with `naming`, switch reviewer to deep naming-only mode.
4. Output: structured review report (Critical → Major → Minor) with file:line, fix per issue, and project-type-specific checks (IPC sync / provider pattern / etc).

> Full playbook details preserved in `.claude/commands/_legacy/audit-code.md.deprecated`.

---

## Playbook: `config` — `.claude/` consistency audit

**Skills**: `architecture-patterns`, `documentation-standards`, `audit-config` (+ `contract-checks.md`)
**Rules**: `no-unused-docs`, `documentation`
**Agent**: `doc-manager` — mode `audit`

Run **three audit levels** (cumulative — L2 requires L1 pass, L3 requires L2 pass):

**L1 — Static checks** (always run):
1. Inventory all documents (rules, commands, agents, skills, hooks, settings).
2. Map references between components.
3. Classify each document (Active / Passive / Dead).
4. Detect issues (dead docs, duplicate content, missing integrations, inconsistencies).
5. Verify pipeline integrity: User → Hook → Command → Agent → Skill/Rule → Output.

**L2 — Semantic contract checks** (per `skills/audit-config/contract-checks.md`):
1. Command ↔ Agent output format contract
2. Command ↔ Skill template alignment
3. Rule path ↔ actual folder convention (legacy aliases)
4. Hook matcher regex ↔ command keyword coverage
5. Agent `skills:` frontmatter ↔ skill folder existence
6. Command `next_on_result` ↔ target command existence
7. `KNOWN_COMMANDS` in `log-command.sh` ↔ actual commands (now dynamic — verify no hardcoded list reintroduced)
8. Agent `## Output Format` section presence

**L3 — Spot-read** (mandatory after recent sync cycles):
- For every command file changed in the last commit, manually read the output-writing step and cross-reference the delegated agent's `## Output Format` section. Report which files were spot-read.

**Output requirement**: Report MUST include Inventory Summary, L1 Issues, Pipeline Verification, L2 Semantic Contract Check, **Audit Coverage Report** (files scanned, invariants checked/skipped, spot-reads performed, confidence). Missing sections = incomplete audit, must NOT be reported as clean.

> Full report template preserved in `.claude/commands/_legacy/audit-config.md.deprecated`.

---

## Playbook: `project` — Architecture audit

**Skills**: `architecture-patterns`, `coding-standards`, `naming-conventions`, `project-context`
**Agent**: `architect`

1. Detect project type.
2. Read `package.json`, `tsconfig.json`, `.gitmodules` → extract stack, scripts, deps, path aliases.
3. Delegate to **architect** agent. The agent runs:
   - Structure scan (file counts, god modules, orphan files, barrel exports)
   - Dependency direction analysis (circular deps, import violations)
   - Type safety scan (any, empty catch, console.log, hardcoded secrets)
   - Project-type-specific audit (IPC sync, provider pattern, process isolation)
   - General checklist
4. Output: Health Score, Project Profile, Tech Stack, Architecture Summary, IPC/Provider inventory (where applicable), Strengths, Critical/Major Issues, Improvement Roadmap, Dependency Summary.

> Full report template preserved in `.claude/commands/_legacy/audit-project.md.deprecated`.

---

## Playbook: `repair` — Fix `.claude/` config issues

**Skills**: `architecture-patterns`, `documentation-standards`
**Rules**: `no-unused-docs`
**Agent**: `doc-manager` — mode `repair`
**MUTATES files** — review changes before committing.

1. Re-run inventory and classification.
2. For dead documents: attach to relevant command/agent OR delete.
3. For missing integrations: add reference in target command/agent.
4. For broken pipelines: create missing agent or add missing skill reference.
5. Output EXACT file paths and changes for each fix.
6. Re-run `/audit config` to verify all issues resolved.
7. Only fix clear-cut issues; flag ambiguous cases for manual review.

---

## Playbook: `diagnose` — Bug investigation

**Skills**: `coding-standards`, `architecture-patterns`, `project-context`
**Rules**: `testing-methodology` (4-step process: Input Assumptions → Flow Analysis → Report → diagnose), `error-patterns`
**Agent**: `debugger`

Examples:
- `/audit diagnose "sync fails after 100 records" src/system/workers/sync`
- `/audit diagnose "scheduler jobs not recovering" src/main/helpers/scheduler`
- `/audit diagnose "IPC timeout on account_create"`

1. Detect project type → apply project-specific debug focus (Electron: IPC errors, process crashes, preload, DB, worker; Library: provider loading, factory, actions).
2. Quick pattern match against `.claude/rules/error-patterns.md`.
3. Delegate to **debugger** agent. The agent runs:
   - Parse problem (expected vs actual)
   - Locate error layer
   - Gather evidence (file:line, logs, traces)
   - Form 3+ hypotheses with evidence
   - Apply 5 Whys to most likely cause
   - Propose solutions ranked by effort/risk
4. Output: Error Location, Evidence, Hypotheses table, Root Cause (5 Whys), Recommended Solutions, Prevention.
5. If solution approved → execute via `/implement` and verify with `npm run flint && npm run typecheck`.

**Notes**:
- For Electron, trace ALL layers (renderer → preload → main → DB).
- If error message is `SOMETHING_WENT_WRONG`, the real error was caught by `custom-ipc.ts` — check inside the handler.
- Check git history for recent changes to affected files.

---

## Notes

- Be specific: always point to file and line.
- Be constructive: every issue needs a fix suggestion.
- Prioritize: Critical → Major → Minor.
- For deep test design after `diagnose` → `/test generate`.
- For structural fixes → `/plan`.
