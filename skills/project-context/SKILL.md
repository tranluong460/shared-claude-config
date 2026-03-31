---
name: project-context
description: MKT Client project context — Electron desktop app for MKT Software management with TypeORM, SQLite, React, and worker-based sync system.
layer: project
---

# Project Context — MKT Client

## Project Identity

| Field       | Value                                                                              |
| ----------- | ---------------------------------------------------------------------------------- |
| Name        | MKT Client                                                                         |
| Type        | Electron App                                                                       |
| Description | Desktop app for managing MKT Software products, sync, scheduling, and auto-updates |
| Version     | 5.4.5                                                                              |
| Company     | MKT SOFTWARE, JSC.                                                                 |

## Tech Stack

| Layer          | Technology                           |
| -------------- | ------------------------------------ |
| Runtime        | Node.js 24.x / Electron 33.x         |
| Language       | TypeScript 5.5                       |
| Database       | TypeORM + better-sqlite3 (SQLite)    |
| UI Framework   | React 18.3                           |
| Build Tool     | electron-vite 2.3                    |
| Test Framework | None configured (vitest recommended) |
| Package Mgr    | yarn (install/add) + npm (scripts)   |

## Build & Test Commands

| Action        | Command                                |
| ------------- | -------------------------------------- |
| Install       | `yarn install`                         |
| Dev           | `npm run dev`                          |
| Build         | `npm run build`                        |
| Lint + Format | `npm run lint` + `npm run format`      |
| Typecheck     | `npm run typecheck`                    |
| Test          | Not configured — bootstrap with vitest |

## Architecture

```
src/
├── main/           # Electron main process
│   ├── ipcs/       # IPC handlers (custom-ipc.ts wraps all)
│   ├── database/   # TypeORM entities, models, AppDataSource
│   ├── helpers/    # Business logic (scheduler, download-manager, worker-sync)
│   └── nodejs/     # Node.js utilities
├── preload/        # Preload scripts (IPC bridge)
│   └── ipc/        # IPC proxy mirrors main/ipcs/
├── renderer/       # React UI
│   └── src/
│       ├── pages/      # Route pages
│       ├── hooks/      # React hooks (useQuery/useMutation)
│       ├── components/ # Shared components
│       └── services/   # API endpoints (window.api.*)
└── system/         # System-level modules
    └── workers/    # Worker threads (sync engine)
```

## Architecture Decisions

1. **IPC 5-layer sync**: types → handler → preload → API → hook — all layers must update together for any IPC change
2. **Worker-based sync**: Sync engine runs in worker threads to avoid blocking main process. Uses message-passing for status updates.
3. **SQLite via better-sqlite3**: Chosen for offline-first desktop app. TypeORM manages schema.
4. **Custom IPC wrapper**: `custom-ipc.ts` wraps all handlers with generic error catching — specific error handling must be added inside each handler.
5. **Scheduler system**: Uses node-schedule for job management with recovery logic on app restart.

## Business Rules & Constraints

- App must work fully offline — all data stored locally in SQLite
- Sync with remote server happens via worker threads, must not block UI
- Auto-update via electron-updater with custom download management
- Products (MKT software) are managed locally with scheduled actions
- Vietnamese is the primary user language

## Known Gotchas

- `custom-ipc.ts` catches ALL errors and returns generic `SOMETHING_WENT_WRONG` — always add specific try-catch inside handlers
- TypeORM entity changes require updating: entity file → EEntityName enum → AppDataSource registration → model file → IPC handler
- `const x: Type | undefined = undefined` causes TS narrowing to `never` — use `const x = undefined as Type | undefined` instead
- Preload IPC proxies must mirror exact channel names from main/ipcs/
- Worker threads use message-passing — no shared memory, no direct DB access from renderer
