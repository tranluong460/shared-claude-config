---
paths:
  - src/**/*.ts
  - src/**/*.tsx
---

# Code Quality Rules (always active)

> Full references: `skills/coding-standards/SKILL.md` | `skills/naming-conventions/SKILL.md`

## Naming

- Enums: `E` prefix — `EPlatform`, `EEntityName`
- Interfaces/Types: `I` prefix — `IUserService`, `IPayloadHistory`
- React Props: `{Component}Props` — NO `I` prefix
- Booleans: `is`/`has`/`can`/`should` — `isActive`, `hasPermission`
- Functions: verb-first — `get` (sync), `fetch` (async/DB), `remove` (collection), `delete` (permanent)
- Constants: `UPPER_SNAKE_CASE` — `MAX_RETRY_COUNT`
- Files: kebab-case — `message-handler.service.ts`
- Folders: kebab-case — `browser-window/`, never `BrowserWindow/`
- IPC channels: `{domain}_{actionCamelCase}` — `account_create`
- DB fields: `snake_case` — `is_auto`, `created_at`

## TypeScript

- No `any` — use `unknown`, generics, or type guards
- Return types required on exported functions
- Max 50 lines per function
- Max 300 lines per file — split by responsibility
- Nesting max 3 levels — use early returns / guard clauses
- 0-2 parameters max — use options object for 3+
- Errors: try-catch at boundaries, typed errors, no silent swallow
- No empty catch blocks — always `logger.error(context, error as Error)`
- No `console.log` — use `logger` (Electron) or `this.logUpdate()` (Library)
- Delete unused imports and variables immediately
- Prefer `const` over `let` — no `var` ever
