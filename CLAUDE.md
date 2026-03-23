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
- Project-specific context: `skills/project-context/SKILL.md` (fill in for your project)
