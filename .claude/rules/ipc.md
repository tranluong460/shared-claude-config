---
paths:
  - 'src/main/ipc/**'
  - 'src/preload/ipc/**'
---

# IPC Rules

## Adding/Changing IPC — ALL 5 layers must sync:

```
1. src/preload/types/ipc.ts     → Define ArgRoutes (args + return type)
2. src/main/ipc/{domain}.ts     → ipcMainHandle('{domain}_{action}', handler)
3. src/main/helper/app/ipc.ts   → Register in registerIPC()
4. src/preload/ipc/{domain}.ts  → ipcRendererInvoke('{domain}_{action}')
5. src/preload/index.ts         → Expose in api object
```

Then renderer side:

```
6. src/renderer/src/services/api/endpoints/{domain}.ts → window.api.{domain}
7. src/renderer/src/services/{domain}/useXxx.ts        → React Query hook
8. src/renderer/src/services/queryKeys.ts              → Add query key
```

## Channel naming

- Pattern: `{domain}_{actionCamelCase}`
- Good: `account_create`, `account_readByField`, `setting_update`
- Bad: `createAccount`, `account-create`, `ACCOUNT_CREATE`

## Handler pattern

- One file per domain — `account.ts`, `setting.ts`, `post.ts`
- Handler > 100 lines → extract to `src/main/services/{domain}.service.ts`
- Use `EPrefixIpcEnum` for domain prefixes — avoid string typos
