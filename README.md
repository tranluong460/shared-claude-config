# .claude — AI Development Toolkit for Node.js / Electron

A reusable AI toolkit for developing Node.js / TypeScript / Electron projects at production quality. Supports Electron apps, module-based libraries (provider/factory pattern), and Node.js servers.

## Quick Start

| I want to...             | Command                                | What happens                                             |
| ------------------------ | -------------------------------------- | -------------------------------------------------------- |
| Review code quality      | `/audit-code src/modules/user`         | Code review with severity-ranked issues                  |
| Audit naming conventions | `/audit-naming src/`                   | Scan names (E/I prefix, A/HC/LC, S-I-D), suggest renames |
| Audit full project       | `/audit-project`                       | Auto-detect type → architecture, IPC, deps, health score |
| Generate tests           | `/generate-tests src/services/auth.ts` | Detect framework → plan → generate tests                 |
| Generate documentation   | `/generate-docs <type>`                | Categorized docs: guides, API, ADR, fix, changelog       |
| Plan refactoring         | `/refactor-plan src/utils/`            | Risk assessment → phased plan                            |
| Debug an issue           | `/diagnose "Error X when Y"`           | Cross-process trace → hypotheses → root cause → fix      |
| Implement changes        | `/implement "refactor auth module"`    | Detect project → recipe-based implement → verify         |
| Independent code review  | `/parallel-review latest`              | Fresh-eyes review in isolated worktree → no bias         |
| Reflect & improve        | `/reflect 1 week`                      | Analyze recent work → find patterns → suggest config fixes |

---

## Architecture

```
Commands  ──call──▶  Agents  ──use──▶  Skills
(actions)           (AI roles)        (knowledge)
```

### Commands (11) — User-Facing Actions

| Command            | Description                 | Agent             | Skills Used                                                                   |
| ------------------ | --------------------------- | ----------------- | ----------------------------------------------------------------------------- |
| `/audit-code`      | Code quality review         | code-reviewer     | coding-standards, naming-conventions, architecture-patterns                   |
| `/audit-naming`    | Naming convention audit     | code-reviewer     | naming-conventions                                                            |
| `/audit-project`   | Full architecture audit     | architect         | architecture-patterns, coding-standards, naming-conventions                   |
| `/generate-tests`  | Test generation             | test-architect    | testing-strategy, coding-standards, naming-conventions                        |
| `/generate-docs`   | Documentation generation    | doc-writer        | documentation-standards                                                       |
| `/refactor-plan`   | Refactoring strategy        | architect         | refactoring-strategy, architecture-patterns, naming-conventions               |
| `/diagnose`        | Bug investigation           | debugger          | coding-standards, architecture-patterns                                       |
| `/implement`       | Execute implementation      | task-executor     | coding-standards, naming-conventions, testing-strategy, architecture-patterns |
| `/parallel-review` | Independent worktree review | parallel-reviewer | coding-standards, naming-conventions, architecture-patterns, testing-strategy |
| `/reflect`         | Session analysis & improve  | reflection-analyzer | reflection, coding-standards                                                  |
| `/audit-docs`      | Audit `.claude/` documentation consistency — detect dead, duplicate, or weakly integrated docs | doc-auditor       | architecture-patterns, documentation-standards                                |

### Agents (9) — AI Roles

| Agent                    | Role                                                 | Primary Skills                                                                    |
| ------------------------ | ---------------------------------------------------- | --------------------------------------------------------------------------------- |
| **architect**            | Analyzes architecture, plans refactoring             | architecture-patterns, coding-standards, refactoring-strategy, naming-conventions |
| **code-reviewer**        | Reviews code quality with Electron/Library awareness | coding-standards, naming-conventions, architecture-patterns                       |
| **parallel-reviewer**    | Independent review in isolated worktree (no bias)    | coding-standards, naming-conventions, architecture-patterns, testing-strategy     |
| **debugger**             | Cross-process debugging, root cause analysis         | coding-standards, architecture-patterns                                           |
| **doc-auditor**          | Enforces .claude/ documentation consistency          | architecture-patterns, documentation-standards                                    |
| **doc-writer**           | Creates and reviews documentation                    | documentation-standards                                                           |
| **reflection-analyzer**  | Analyzes sessions, detects patterns, suggests fixes  | reflection, coding-standards                                                      |
| **task-executor**        | Implements changes with project-aware recipes        | coding-standards, naming-conventions, testing-strategy, architecture-patterns     |
| **test-architect**       | Test strategy with Electron/Library mock patterns    | testing-strategy, coding-standards, naming-conventions                            |

### Skills (8) — Knowledge Modules

| Skill                       | Content                                                                                               |
| --------------------------- | ----------------------------------------------------------------------------------------------------- |
| **coding-standards**        | Clean code, TypeScript best practices, error handling, anti-patterns                                  |
| **naming-conventions**      | S-I-D, A/HC/LC, E prefix (enums), I prefix (interfaces/types), IPC channels, React naming             |
| **testing-strategy**        | Test design, AAA pattern, mocking, Electron/Library test guides, bootstrap                            |
| **documentation-standards** | Categorized docs structure, templates for guides, ADR, API, IPC, entities, troubleshooting, changelog |
| **architecture-patterns**   | Electron (IPC, process isolation), provider/factory pattern, dependency rules, audit checklists       |
| **refactoring-strategy**    | Techniques, risk assessment, Electron/Library recipes, incremental migration                          |
| **reflection**              | Session analysis, self-improvement loop, recurring mistake detection, config improvement suggestions  |
| **testing-methodology**     | 4-step analysis process: Input Assumptions, Flow Analysis, Report, Implement                          |

### Rules (13) — Context-Aware Enforcement

Rules auto-inject when Claude works on matching files. Unlike skills (full knowledge), rules are short enforcement directives.

| Rule                 | Paths                                   | Enforces                                                |
| -------------------- | --------------------------------------- | ------------------------------------------------------- |
| **typescript**       | `src/**/*.ts,tsx`                       | No `any`, return types, max 50 lines, error handling    |
| **naming**           | `src/**/*.ts,tsx`                       | E/I prefix, IPC naming, kebab-case, boolean prefix      |
| **electron**         | `src/main,preload,renderer/**`          | Process isolation, IPC via preload, no Node in renderer |
| **ipc**              | `src/main/ipc/**`, `src/preload/ipc/**` | 5-layer sync, channel naming, handler pattern           |
| **database**         | `src/main/database/**`                  | Entity pattern, Model pattern, IMainResponse            |
| **react**            | `src/renderer/src/**`                   | React Query, hooks, Props naming, i18n                  |
| **testing**          | `**/*.test.ts`, `test/**`               | AAA, vitest, mock patterns                              |
| **implementation**   | `src/**`                                | Read before write, verify commands, multi-file IPC      |
| **error-patterns**   | `src/**`                                | Common errors quick reference table                     |
| **provider-pattern** | `src/providers/**`, `src/core/**`       | Provider structure, action rules, barrel exports        |
| **testing-methodology** | `src/**`                             | 4-step analysis process: Input → Flow → Report → Implement |
| **documentation**    | `docs/**`                               | Folder structure, file naming, when to create docs      |
| **no-unused-docs**   | `.claude/**`                            | Every .claude/ doc must be referenced; run /audit-docs  |

---

## Workflow

The toolkit supports the full development improvement cycle:

```
/audit-project          Understand current state
        ↓
/audit-code + /audit-naming  Identify specific issues
        ↓
/refactor-plan          Plan the improvements
        ↓
/generate-tests         Add test safety net
        ↓
/implement              Execute the plan
        ↓
/parallel-review        Independent quality gate
        ↓
/generate-docs          Document what changed
        ↓
/reflect                Weekly: analyze patterns → improve config
```

### Bug Fix Flow

```
/diagnose               Find root cause
        ↓
/implement              Apply the fix + regression test
        ↓
/audit-code             Verify fix quality
```

---

## Customization

### Adding Project-Specific Context

Create a `skills/project-context/SKILL.md` with:

- Project tech stack
- Build and test commands
- Architecture decisions specific to your project
- Business rules and constraints

### Adding New Commands

Create `commands/<name>.md` with:

```yaml
---
description: What this command does
---
```

Then define the workflow: which agent to use, which skills to load.

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

| Hook                     | Event              | Script / Type                        | What it does                                                            |
| ------------------------ | ------------------ | ------------------------------------ | ----------------------------------------------------------------------- |
| Suggest commands         | `UserPromptSubmit` | `hooks/suggest-commands.sh`          | Auto-suggest relevant `/commands` based on user prompt keywords         |
| Block dangerous commands | `PreToolUse`       | `hooks/block-dangerous-commands.sh`  | Blocks `rm -rf`, `git push --force`, `chmod 777`, `curl\|sh`, etc.     |
| Auto-format after edit   | `PostToolUse`      | `hooks/auto-format.sh`              | Runs `prettier --write` on `.ts`/`.tsx` files                           |
| Context persistence      | `PostCompact`      | inline                               | Re-injects rules reminder, active tasks, `/clear` vs `/compact` tip    |
| Notification on finish   | `Stop`             | inline                               | System sound (Windows) / native notification (macOS/Linux)              |

### Hooks Directory

External scripts in `.claude/hooks/` — readable, testable, maintainable:

```
.claude/hooks/
├── block-dangerous-commands.sh   # PreToolUse: deny dangerous bash patterns
├── auto-format.sh                # PostToolUse: prettier for .ts/.tsx
└── suggest-commands.sh           # UserPromptSubmit: keyword → command suggestion
```

### Permissions

- **Allow**: Bash, all Claude tools (Read, Write, Edit, Grep, Glob, WebSearch, WebFetch)
- **Deny**: `.env`, credentials, secrets, SSH keys, GPG, Docker config, Kubernetes config, shell profiles — never read or edit

---

## Design Principles

- **Generic**: Works with Electron apps, module-based libraries, and Node.js servers
- **Modular**: Each component has a single responsibility
- **Extensible**: Add project-specific skills without modifying core
- **Practical**: Every command produces actionable output
- **Framework-agnostic**: Auto-detects test framework, package manager, project structure
- **No duplicate knowledge**: Each piece of knowledge defined in exactly one place
- **Clean boundaries**: Commands delegate, agents reason, skills provide knowledge
