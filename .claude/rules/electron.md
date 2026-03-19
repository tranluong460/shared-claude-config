---
paths:
  - 'src/main/**'
  - 'src/preload/**'
  - 'src/renderer/**'
---

# Electron Process Rules

## Renderer (src/renderer/)

- NEVER import `fs`, `path`, `child_process`, or any Node.js module
- NEVER use `ipcRenderer` directly — always use `window.api.{domain}.{method}()`
- All async data through React Query hooks (`useQuery`, `useMutation`)
- Invalidate queries via `queriesToInvalidate([queryKeys.xxx])` on mutation success
- Toast notifications: `toast[result.status](t(result.message.key))`

## Preload (src/preload/)

- MUST mirror every `main/ipc/` handler with matching proxy
- Use `ipcRendererInvoke('{domain}_{action}', payload)` — nothing else
- NO business logic — thin pass-through only
- Types defined in `preload/types/ipc.ts` with `ArgRoutes`

## Main (src/main/)

- Heavy operations → worker threads, never block main process
- Use `ipcMainHandle()` from `custom-ipc.ts` — auto-wraps with error handler
- Return `createResponse(messageKey, status, { data })` — always `IMainResponse<T>`
- Use `logger.error(context, error as Error)` — never console.log
