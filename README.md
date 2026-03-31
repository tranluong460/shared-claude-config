# .claude — AI Development Toolkit for Node.js / Electron

A reusable AI toolkit for developing Node.js / TypeScript / Electron projects at production quality. Supports Electron apps, module-based libraries (provider/factory pattern), and Node.js servers.

## Quick Start

| I want to...             | Command                                | What happens                                               |
| ------------------------ | -------------------------------------- | ---------------------------------------------------------- |
| Review code quality      | `/audit-code src/modules/user`         | Code review with severity-ranked issues                    |
| Audit naming conventions | `/audit-code naming src/`              | Deep naming scan (E/I prefix, A/HC/LC, S-I-D)              |
| Audit full project       | `/audit-project`                       | Auto-detect type → architecture, IPC, deps, health score   |
| Audit .claude/ docs      | `/audit-docs`                          | Detect dead, duplicate, or weakly integrated docs          |
| Fix .claude/ doc issues  | `/repair-docs`                         | Fix documentation issues found by /audit-docs              |
| Generate tests           | `/generate-tests src/services/auth.ts` | Detect framework → plan → generate tests                   |
| Generate documentation   | `/generate-docs <type>`                | Categorized docs: guides, API, ADR, fix, changelog         |
| Plan refactoring         | `/refactor-plan src/utils/`            | Risk assessment → phased plan                              |
| Debug an issue           | `/diagnose "Error X when Y"`           | Cross-process trace → hypotheses → root cause → fix        |
| Implement changes        | `/implement "refactor auth module"`    | Detect project → recipe-based implement → verify           |
| Independent code review  | `/parallel-review latest`              | Fresh-eyes review in isolated worktree → no bias           |
| Production readiness     | `/test-system src/main/sync`           | Multi-agent risk analysis → failure scenarios → judgment   |
| Reflect & improve        | `/reflect 1 week`                      | Analyze recent work → find patterns → suggest config fixes |

---

## Architecture

```
CLAUDE.md (entry point)
    ↓
Commands  ──call──▶  Agents  ──use──▶  Skills
(actions)           (AI roles)        (knowledge)
```

### Commands (12) — User-Facing Actions

| Command            | Category | Description                                                             | Agent               | Skills Used                                                                                    |
| ------------------ | -------- | ----------------------------------------------------------------------- | ------------------- | ---------------------------------------------------------------------------------------------- |
| `/audit-code`      | audit    | Code quality + naming review (use `naming` prefix for naming-only mode) | reviewer            | coding-standards, naming-conventions, architecture-patterns                                    |
| `/audit-project`   | audit    | Full architecture audit                                                 | architect           | architecture-patterns, coding-standards, naming-conventions, project-context                   |
| `/audit-docs`      | audit    | .claude/ documentation audit (read-only)                                | doc-auditor         | architecture-patterns, documentation-standards                                                 |
| `/repair-docs`     | execute  | Fix issues found by /audit-docs                                         | doc-auditor         | architecture-patterns, documentation-standards                                                 |
| `/diagnose`        | analyze  | Bug investigation                                                       | debugger            | coding-standards, architecture-patterns, project-context                                       |
| `/refactor-plan`   | plan     | Refactoring strategy                                                    | architect           | refactoring-strategy, architecture-patterns, naming-conventions                                |
| `/generate-tests`  | execute  | Test generation                                                         | test-architect      | testing-strategy, coding-standards, naming-conventions, project-context                        |
| `/generate-docs`   | execute  | Documentation generation                                                | doc-writer          | documentation-standards, project-context                                                       |
| `/implement`       | execute  | Execute implementation                                                  | task-executor       | coding-standards, naming-conventions, testing-strategy, architecture-patterns, project-context |
| `/parallel-review` | verify   | Independent worktree review                                             | reviewer            | coding-standards, naming-conventions, architecture-patterns, testing-strategy                  |
| `/test-system`     | verify   | Production readiness testing                                            | test-leader         | production-testing, coding-standards, architecture-patterns, testing-strategy, project-context |
| `/reflect`         | improve  | Session analysis & improve                                              | reflection-analyzer | reflection, coding-standards                                                                   |

### Agents (9) — AI Roles

| Agent                   | Role                                                                        | Primary Skills                                                                                                      |
| ----------------------- | --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **architect**           | Analyzes architecture, plans refactoring                                    | architecture-patterns, coding-standards, refactoring-strategy, naming-conventions, project-context                  |
| **reviewer**            | Reviews code quality (standard + independent worktree modes)                | coding-standards, naming-conventions, architecture-patterns, testing-strategy                                       |
| **debugger**            | Cross-process debugging, root cause analysis                                | coding-standards, architecture-patterns, testing-methodology, project-context                                       |
| **doc-auditor**         | Audits and repairs .claude/ documentation consistency                       | architecture-patterns, documentation-standards                                                                      |
| **doc-writer**          | Creates and reviews documentation                                           | documentation-standards, project-context                                                                            |
| **reflection-analyzer** | Analyzes sessions, detects patterns, suggests fixes                         | reflection, coding-standards                                                                                        |
| **task-executor**       | Implements changes with project-aware recipes                               | coding-standards, naming-conventions, testing-strategy, architecture-patterns, testing-methodology, project-context |
| **test-architect**      | Test strategy with Electron/Library mock patterns                           | testing-strategy, coding-standards, naming-conventions, project-context                                             |
| **test-leader**         | Production testing team leader — risk analysis, failure scenarios, judgment | production-testing, coding-standards, architecture-patterns, testing-strategy, project-context                      |

### Skills (10) — Knowledge Modules

| Skill                       | Layer        | Content                                                                                                |
| --------------------------- | ------------ | ------------------------------------------------------------------------------------------------------ |
| **coding-standards**        | core         | Clean code, TypeScript best practices, error handling, anti-patterns                                   |
| **naming-conventions**      | core         | S-I-D, A/HC/LC, E prefix (enums), I prefix (interfaces/types), IPC channels, React naming              |
| **documentation-standards** | core         | Categorized docs structure, templates for guides, ADR, API, IPC, entities, troubleshooting, changelog  |
| **architecture-patterns**   | architecture | Electron (IPC, process isolation), provider/factory pattern, dependency rules, audit checklists        |
| **refactoring-strategy**    | architecture | Techniques, risk assessment, Electron/Library recipes, incremental migration                           |
| **testing-strategy**        | testing      | Test design, AAA pattern, mocking, Electron/Library test guides, bootstrap                             |
| **testing-methodology**     | workflow     | 4-step analysis process: Input Assumptions, Flow Analysis, Report, Implement                           |
| **production-testing**      | testing      | Multi-agent production testing: risk assessment, failure imagination, proof-based validation, judgment |
| **reflection**              | workflow     | Session analysis, self-improvement loop, recurring mistake detection, config improvement suggestions   |
| **project-context**         | project      | MKT Client: Electron + TypeORM + SQLite + React, architecture decisions, business rules                |

### Rules (13) — Context-Aware Enforcement

Rules auto-inject when Claude works on matching files. Unlike skills (full knowledge), rules are short enforcement directives.

| Rule                    | Paths                                   | Enforces                                                                  |
| ----------------------- | --------------------------------------- | ------------------------------------------------------------------------- |
| **code-quality**        | `src/**/*.ts,tsx`                       | No `any`, return types, max 50 lines, naming (E/I prefix), error handling |
| **electron**            | `src/main,preload,renderer/**`          | Process isolation, IPC via preload, no Node in renderer                   |
| **ipc**                 | `src/main/ipc/**`, `src/preload/ipc/**` | 5-layer sync, channel naming, handler pattern                             |
| **database**            | `src/main/database/**`                  | Entity pattern, Model pattern, IMainResponse                              |
| **react**               | `src/renderer/src/**`                   | React Query, hooks, Props naming, i18n                                    |
| **testing**             | `**/*.test.ts`, `test/**`               | AAA, vitest, mock patterns                                                |
| **implementation**      | `src/**`                                | Read before write, verify commands, multi-file IPC                        |
| **error-patterns**      | `src/**`                                | Common errors quick reference table                                       |
| **provider-pattern**    | `src/providers/**`, `src/core/**`       | Provider structure, action rules, barrel exports                          |
| **project-detection**   | (auto-detect)                           | Identify project type: Electron / Library / Server                        |
| **testing-methodology** | `src/**`                                | 4-step analysis process: Input → Flow → Report → Implement                |
| **documentation**       | `docs/**`                               | Folder structure, file naming, when to create docs                        |
| **no-unused-docs**      | `.claude/**`                            | Every .claude/ doc must be referenced; run /audit-docs                    |

---

## Workflow

The toolkit supports the full development improvement cycle:

```
/audit-project          Understand current state
        ↓
/audit-code              Identify specific issues (use "naming" prefix for naming-only)
        ↓
/audit-docs             Check .claude/ consistency
        ↓               (/repair-docs to fix)
/refactor-plan          Plan the improvements
        ↓
/generate-tests         Add test safety net
        ↓
/implement              Execute the plan
        ↓
/parallel-review        Independent quality gate
        ↓
/test-system            Production readiness check
        ↓
/generate-docs          Document what changed
        ↓
/reflect                Weekly: analyze patterns → improve config
```

### Bug Fix Flow

```
/diagnose               Find root cause
        ↓
/generate-tests         Regression test
        ↓
/implement              Apply the fix
        ↓
/audit-code             Verify fix quality
```

---

## Customization

### Adding Project-Specific Context

Fill in the template at `skills/project-context/SKILL.md` with:

- Project tech stack
- Build and test commands
- Architecture decisions specific to your project
- Business rules and constraints

### Adding New Commands

Create `commands/<name>.md` with:

```yaml
---
description: What this command does
category: audit|plan|execute|verify|analyze|improve
mutates: false
consumes: [source-code]
produces: [report]
result_states: [state_a, state_b, execution_error]
next_on_result:
  state_a: [follow-up-command]
  state_b: [other-command]
  execution_error: [diagnose]
---
```

Then define the workflow: which agent to use, which skills to load.

> **Important**: `result_states` must reflect **business outcomes**, not execution status. An audit that runs successfully but finds issues has result `issues_found`, not `success`.

### Adding New Skills

Create `skills/<name>/SKILL.md` with:

```yaml
---
name: <skill-name>
description: <what knowledge this provides>
---
```

---

## Hooks & Safety (settings.json)

| Hook                     | Event              | Script / Type                       | What it does                                                        |
| ------------------------ | ------------------ | ----------------------------------- | ------------------------------------------------------------------- |
| Suggest commands         | `UserPromptSubmit` | `hooks/suggest-commands.sh`         | Auto-suggest `/commands` based on keywords + result-state detection |
| Block dangerous commands | `PreToolUse`       | `hooks/block-dangerous-commands.sh` | Blocks `rm -rf`, `git push --force`, `chmod 777`, `curl\|sh`, etc.  |
| Log commands             | `UserPromptSubmit` | `hooks/log-command.sh`              | Logs `/command` invocations to `memory/command-history.jsonl`       |
| Auto-format after edit   | `PostToolUse`      | `hooks/auto-format.sh`              | Runs `prettier --write` on `.ts`/`.tsx` files                       |
| Code quality enforcement | `PostToolUse`      | `hooks/check-code-quality.sh`       | Checks `any` type, `console.log`, 50-line/300-line limits           |
| Context persistence      | `PostCompact`      | `hooks/post-compact.sh`             | Re-injects rules, modified files, branch, lessons, active tasks     |
| Notification on finish   | `Stop`             | inline                              | System sound (Windows) / native notification (macOS/Linux)          |

### Hooks Directory

External scripts in `.claude/hooks/` — readable, testable, maintainable:

```
.claude/hooks/
├── block-dangerous-commands.sh   # PreToolUse: deny dangerous bash patterns
├── log-command.sh                # UserPromptSubmit: log /command invocations to memory/command-history.jsonl
├── auto-format.sh                # PostToolUse: prettier for .ts/.tsx
├── check-code-quality.sh         # PostToolUse: enforce no-any, no-console.log, line limits
├── post-compact.sh               # PostCompact: restore context (rules, files, branch, lessons)
└── suggest-commands.sh           # UserPromptSubmit: keyword + result-state → command suggestion
```

### Permissions

- **Allow**: Bash, all Claude tools (Read, Write, Edit, Grep, Glob, WebSearch, WebFetch)
- **Deny**: `.env`, credentials, secrets, SSH keys, GPG, Docker config, Kubernetes config, shell profiles — never read or edit

---

## Infrastructure

### Memory (`memory/`)

Persistence layer for reflection and telemetry:

- `lessons.md` — Accumulated insights from `/reflect` sessions (self-improving loop)
- `command-history.jsonl` — Command invocation log (used by `/reflect` for usage analysis)

---

## Design Principles

- **Generic**: Works with Electron apps, module-based libraries, and Node.js servers
- **Modular**: Each component has a single responsibility
- **Extensible**: Add project-specific skills without modifying core
- **Practical**: Every command produces actionable output
- **Framework-agnostic**: Auto-detects test framework, package manager, project structure
- **No duplicate knowledge**: Each piece of knowledge defined in exactly one place
- **Clean boundaries**: Commands delegate, agents reason, skills provide knowledge
