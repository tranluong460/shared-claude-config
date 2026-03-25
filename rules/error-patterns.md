---
paths:
  - src/**
---

# Common Error Quick Reference (always active)

> This is the canonical error table. Agents and commands reference here — do not duplicate.

## Electron Errors

| Error                                             | Cause                            | Look here                                            |
| ------------------------------------------------- | -------------------------------- | ---------------------------------------------------- |
| `SOMETHING_WENT_WRONG`                            | Handler threw uncaught error     | `src/main/ipc/` — the actual handler code            |
| `Cannot read properties of undefined`             | IPC response shape mismatch      | Check `.payload.data` extraction in hook             |
| `SQLITE_BUSY` / `SQLITE_LOCKED`                   | WAL mode or concurrent write     | `AppDataSource.ts` — check enableWAL                 |
| `EntityMetadataNotFoundError`                     | Entity not in DataSource         | `entities` array in AppDataSource                    |
| `ipcMain.handle already registered`               | Duplicate registration           | `registerIPC()` in `helper/app/ipc.ts`               |
| Worker silent failure                             | Unhandled error in thread        | `nodejs/worker/` error handling                      |
| Window white screen                               | Renderer crash                   | `electron.vite.config.ts`, devtools console          |
| `contextBridge API can only be used from preload` | Wrong import or process          | Check if renderer imports Node.js modules            |
| `Unhandled rejection` in main process             | Missing try-catch in IPC handler | Check handler in `src/main/ipc/`                     |
| App opens twice                                   | Missing single instance lock     | Check `requestSingleInstanceLock()` in main/index.ts |

## Library Errors

| Error                                | Cause                                           | Look here                                        |
| ------------------------------------ | ----------------------------------------------- | ------------------------------------------------ |
| `No register in {provider}`          | Missing register() export                       | `providers/{name}/index.ts`                      |
| `No factory registered for '{type}'` | Plugin not loaded or register() not called      | `LabsPluginLoader.ts`, `LabsProviderRegistry.ts` |
| `Failed to load {provider}`          | Dynamic import error                            | Provider directory structure                     |
| Provider start() does nothing        | Action not instantiated in provider constructor | Check `src/providers/{name}/provider.ts`         |
| logUpdate silent fail                | Callback not in payload                         | Caller's payload construction                    |

## Debug approach

1. Identify which layer (renderer → preload → main → DB)
2. Check error handling at that layer
3. If `SOMETHING_WENT_WRONG` → real error is in the handler, not in custom-ipc.ts
