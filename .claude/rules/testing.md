---
paths:
  - '**/*.test.ts'
  - '**/*.spec.ts'
  - 'test/**'
  - 'src/**/__tests__/**'
---

# Testing Rules

> Mock patterns, testability guides, bootstrap: `skills/testing-strategy/SKILL.md`

- Framework: vitest — `import { describe, it, expect, vi } from 'vitest'`
- Pattern: AAA — Arrange → Act → Assert (clearly separated)
- One behavior per `it()` — never test multiple things
- Literal expected values — never replicate implementation logic
- Reset mocks: `vi.clearAllMocks()` in `beforeEach`
- Test name: `it('<expected behavior> when <condition>')`

## What to mock

- TypeORM repos → `vi.fn()` for find/save/delete/createQueryBuilder
- `window.api` → `vi.stubGlobal('window', { api: {...} })`
- `logUpdate` callback → `vi.fn().mockResolvedValue(true)`

## What NOT to test

- Preload proxies (thin wrappers)
- API endpoints (thin wrappers)
- CSS/styling
