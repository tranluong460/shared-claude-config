# Naming Rules (always active)

> Full reference with examples, A/HC/LC pattern, action verbs: `skills/naming-conventions/SKILL.md`

- Enums: `E` prefix — `EPlatform`, `EEntityName`, `EUserRole`
- Interfaces: `I` prefix — `IUserService`, `IPayloadHistory`
- Types: `I` prefix — `ITaskName`, `IDayValue`
- React Props: `{Component}Props` — NO `I` prefix
- Booleans: `is`/`has`/`can`/`should` prefix — `isActive`, `hasPermission`
- Functions: verb-first (A/HC/LC) — `get` (sync), `fetch` (async/DB), `remove` (collection), `delete` (permanent)
- Constants: `UPPER_SNAKE_CASE` — `MAX_RETRY_COUNT`
- Files: kebab-case — `message-handler.service.ts`
- Folders: kebab-case — `browser-window/`, never `BrowserWindow/` or `direct_api/`
- IPC channels: `{domain}_{actionCamelCase}` — `account_create`, `setting_update`
- DB fields: `snake_case` — `is_auto`, `created_at`
