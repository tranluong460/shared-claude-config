---
name: testing-strategy
description: Test design patterns, mock strategies, and project-specific testing guides. Test rules enforced via .claude/rules/testing.md — this skill provides mock pattern examples and testability guides.
---

# Testing Strategy — Reference

> Test enforcement rules are in `.claude/rules/testing.md`. This skill provides mock patterns, testability guides, and bootstrap instructions.

## Testing Pyramid

| Type        | Speed  | Mock policy                 | File pattern    |
| ----------- | ------ | --------------------------- | --------------- |
| Unit        | < 50ms | Mock all external I/O       | `*.test.ts`     |
| Integration | < 5s   | Mock external services only | `*.int.test.ts` |
| E2E         | < 30s  | No mocks                    | `*.e2e.test.ts` |

## AAA Pattern

```typescript
it('calculates total with tax', () => {
  // Arrange
  const items = [{ price: 100 }, { price: 200 }]
  // Act
  const total = calculateTotal(items, 0.1)
  // Assert
  expect(total).toBe(330)
})
```

## Electron Testability Guide

| Layer             | ROI     | Mock strategy               |
| ----------------- | ------- | --------------------------- |
| Helper functions  | Highest | No mocks                    |
| Database models   | High    | Mock TypeORM repo           |
| Worker actions    | High    | Mock dependencies           |
| Utility functions | High    | No mocks                    |
| IPC handlers      | Medium  | Extract to service, mock DB |
| React hooks       | Medium  | Mock window.api             |
| Preload proxies   | Skip    | Thin wrappers               |

### Electron Mock Patterns

```typescript
// TypeORM repository
const mockRepo = {
  find: vi.fn(),
  findOne: vi.fn(),
  save: vi.fn(),
  createQueryBuilder: vi.fn(() => ({
    where: vi.fn().mockReturnThis(),
    getMany: vi.fn().mockResolvedValue([])
  }))
}

// window.api
vi.stubGlobal('window', {
  api: { account: { create: vi.fn(), readAccountByField: vi.fn() } }
})

// electron-store
vi.mock('electron-store', () => ({
  default: class {
    get = vi.fn()
    set = vi.fn()
  }
}))
```

## Library Testability Guide

| Layer                | ROI     | Mock strategy  |
| -------------------- | ------- | -------------- |
| Provider lifecycle   | Highest | Mock logUpdate |
| Action execution     | High    | Mock logUpdate |
| Factory creation     | High    | Verify type    |
| HTTP client          | Medium  | Mock axios     |
| Error classification | Medium  | Pure functions |

### Library Mock Patterns

```typescript
// logUpdate callback
const mockLogUpdate = vi.fn().mockResolvedValue(true)
const payload = {
  type: EnumLabsProvider.AUTOMATED,
  keyTarget: 'test',
  logUpdate: mockLogUpdate,
  example: { example1: 'test', example2: 1 }
}

// axios
vi.mock('axios', () => ({
  default: {
    create: vi.fn(() => ({
      get: vi.fn(),
      post: vi.fn(),
      interceptors: { request: { use: vi.fn() }, response: { use: vi.fn() } }
    }))
  }
}))
```

## Bootstrap (no test infra)

```bash
yarn add -D vitest @vitest/coverage-v8
```

```json
{ "test": "vitest --run", "test:watch": "vitest", "test:coverage": "vitest --coverage" }
```

## Edge Cases Checklist

- `null` / `undefined` / empty string / empty array / zero / negative numbers
- Very large input / special characters / concurrent calls / network timeout
