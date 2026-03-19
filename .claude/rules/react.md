---
paths:
  - 'src/renderer/src/**'
---

# React / Renderer Rules

## Components

- PascalCase file + function: `ButtonActionControl.tsx`
- Props type: `{Component}Props` (no I prefix)
- Layouts: `Layout{Name}.tsx`

## Hooks

- File: `use{Name}.ts` — `useModal.ts`, `useCustomFormik.ts`
- Read data: `useQuery()` with `queryKeys.{domain}.{action}`
- Write data: `useMutation()` with `queriesToInvalidate()` on success
- Toast on result: `toast[result.status](t(result.message.key))`

## Services

- API endpoint: `{Domain}Api` object in `services/api/endpoints/{domain}.ts`
- Calls: `window.api.{domain}.{method}(payload)`
- Hook barrel export: `services/index.ts`

## State

- Server state: React Query (TanStack Query) — NEVER local useState for async data
- Local UI state: `useState` — modals, filters, toggles
- No Redux, no Zustand — React Query handles all server state

## i18n

- Always use `t(key)` from `useTranslation()` for user-facing text
- Translation files: `assets/locales/{lang}/translation.json`
