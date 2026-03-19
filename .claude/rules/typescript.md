---
paths:
  - 'src/**/*.ts'
  - 'src/**/*.tsx'
---

# TypeScript Rules

> Full coding standards, anti-patterns, error handling: `skills/coding-standards/SKILL.md`

- NO `any` — use `unknown` + type guards. Exception: only when wrapping untyped 3rd-party libraries with documented reason
- Exported functions MUST have explicit return types
- Max 50 lines per function — extract helpers when exceeded
- Max 300 lines per file — split by responsibility
- Nesting max 3 levels — use early returns / guard clauses
- 0-2 parameters max — use options object for 3+
- No empty catch blocks — always `logger.error(context, error as Error)` + return typed response
- No `console.log` — use `logger` (Winston) in main, `this.logUpdate()` in library actions
- Delete unused imports and variables immediately
- Prefer `const` over `let` — no `var` ever
