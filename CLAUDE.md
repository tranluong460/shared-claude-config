# AI Development Toolkit

This project uses a modular `.claude/` configuration system for AI-assisted development of Node.js / TypeScript / Electron projects.

## System Architecture

```
Commands (commands/*.md)  ──call──▶  Agents (agents/*.md)  ──use──▶  Skills (skills/*/SKILL.md)
(user actions)                       (AI roles)                      (knowledge modules)
```

- **Rules** (`rules/*.md`): Auto-inject enforcement directives when editing matching file paths
- **Hooks** (`hooks/*.sh`): Automated triggers for safety, formatting, and command suggestions

## Critical Rules (Always Follow)

- No `any` type. Return types required. Max 50 lines per function. Max 300 lines per file.
- Naming: `E` prefix (enums), `I` prefix (interfaces/types), verb-first functions, kebab-case files.
- IPC changes must update ALL layers: types → handler → preload → API → hook.
- Verify: `npm run flint` → `npm run typecheck` before declaring done.
- Package manager: `yarn install/add` for dependencies, `npm run` for scripts.

## Quick Reference

| Goal | Command |
|------|---------|
| Review code quality | `/audit-code <scope>` |
| Audit naming conventions | `/audit-naming <scope>` |
| Full project audit | `/audit-project` |
| Audit .claude/ docs | `/audit-docs` |
| Fix .claude/ doc issues | `/repair-docs` |
| Debug an issue | `/diagnose "<description>"` |
| Plan refactoring | `/refactor-plan <scope>` |
| Generate tests | `/generate-tests <file>` |
| Implement changes | `/implement "<task>"` |
| Generate documentation | `/generate-docs <type>` |
| Independent review | `/parallel-review latest` |
| Reflect & improve | `/reflect 1 week` |

## Key Pointers

- Full command list, workflow diagrams, and design principles: see `README.md`
- Coding standards: `skills/coding-standards/SKILL.md`
- Architecture patterns: `skills/architecture-patterns/SKILL.md`
- Naming conventions: `skills/naming-conventions/SKILL.md`
- Testing methodology: `skills/testing-methodology/SKILL.md`
- Orchestration contracts: `skills/orchestration-contracts/SKILL.md`
- Project-specific context: `skills/project-context/SKILL.md` (fill in for your project)

## Infrastructure

- **Workflows**: `workflows/*.yaml` — formalized command pipelines with result-semantic transitions (feature-delivery, bug-fix, docs-repair)
- **Orchestrator**: `agents/orchestrator.md` — reads workflow YAML, classifies results by business outcome, manages step transitions
- **Memory**: `memory/lessons.md` — accumulated `/reflect` insights; `memory/command-history.jsonl` — auto-logged command invocations; `memory/workflow-runs/` — per-run artifacts
- **Configs**: `configs/command-contracts.schema.json` + `configs/workflow-contracts.schema.json` — JSON Schema for frontmatter and workflow validation
- **Scripts**: `scripts/validate-graph.sh` — validates command graph integrity and workflow result-state coverage

## Command Metadata

Every command has `result_states` and `next_on_result` metadata in its frontmatter, enabling workflow chaining based on **business outcomes** (not just execution success/fail). The `orchestrator` agent reads workflow YAML definitions and manages step transitions using these result semantics. The `suggest-commands.sh` hook also detects result-state language to suggest next steps.
