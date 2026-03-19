---
name: coding-standards
description: Clean code principles, TypeScript best practices, anti-patterns, error handling, and logging conventions for Node.js / Electron / TypeScript projects.
---

# Coding Standards for Node.js / TypeScript

## Core Principles

- **Simplicity First**: The simplest solution that works correctly is the best solution
- **No Unused Code**: Delete dead code immediately — Git preserves history (YAGNI)
- **Single Responsibility**: One module, one purpose
- **Fail Fast**: Surface errors immediately, never suppress them

## Anti-Patterns — Stop Immediately When Detected

### Code Quality

1. **Same code written 3+ times** — Extract (Rule of Three)
2. **Multiple responsibilities in one file** — Split by concern
3. **Same constant defined in multiple files** — Centralize
4. **Commented-out code** — Delete, use version control

> TypeScript-specific anti-patterns (`any`, empty catch, etc.) are in the TypeScript Type Safety and Error Handling sections below.

### Design

- **"Make it work for now"** — Accumulates technical debt exponentially
- **Patching without understanding root cause** — Use 5 Whys first
- **Optimistic assumptions about unfamiliar libraries** — Prototype first
- **Large changes without incremental plan** — Break into phases

## TypeScript Type Safety

> Enforcement rules: `.claude/rules/typescript.md`

### Data Flow Model

```
Input (unknown) → Type Guard → Business Logic (typed) → Output (serialized)
```

### `any` Alternatives (Priority Order)

1. `unknown` + type guards — For external input validation
2. Generics — When type flexibility is needed
3. Union / intersection types — Combining multiple types
4. Type assertions (last resort) — Only when type is provably correct

### Type Guard Pattern

```typescript
function isUser(value: unknown): value is User {
  return typeof value === 'object' && value !== null && 'id' in value && 'email' in value
}
```

### Type Complexity Limits

| Metric                   | Threshold  | Action when exceeded       |
| ------------------------ | ---------- | -------------------------- |
| Fields per type          | ≤ 20       | Split by responsibility    |
| Optional ratio           | ≤ 30%      | Separate required/optional |
| Nesting depth            | ≤ 3 levels | Flatten                    |
| Type assertions per file | ≤ 3        | Review design              |

## Error Handling

### Fail-Fast Principle

```typescript
// WRONG: Silent fallback
catch (error) {
  return defaultValue
}

// RIGHT: Explicit failure
catch (error) {
  logger.error('Operation failed', { error, context })
  throw error
}
```

### Result Type Pattern

```typescript
type Result<T, E = Error> = { ok: true; value: T } | { ok: false; error: E }

function parseConfig(raw: unknown): Result<AppConfig, ValidationError> {
  if (!isValidConfig(raw)) {
    return { ok: false, error: new ValidationError('Invalid config') }
  }
  return { ok: true, value: raw as AppConfig }
}
```

### Custom Error Classes

```typescript
export class AppError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly statusCode = 500
  ) {
    super(message)
    this.name = this.constructor.name
  }
}
```

### Async Error Handling

- Always use `try-catch` with `async/await`
- Set up global handlers: `unhandledRejection`, `uncaughtException`
- Log errors with structured context before re-throwing

### IPC Error Handling (Electron)

IPC handlers are wrapped by `custom-ipc.ts` which catches all errors and returns a generic `SOMETHING_WENT_WRONG`. Always add specific error handling inside handlers:

```typescript
// WRONG: Let custom-ipc catch everything (loses error context)
ipcMainHandle('account_create', async (_, payload) => {
  return await AccountModel.upsert(payload) // throws → generic error
})

// RIGHT: Handle errors explicitly with context
ipcMainHandle('account_create', async (_, payload) => {
  try {
    return await AccountModel.upsert(payload)
  } catch (error) {
    logger.error('[account_create] Failed:', error)
    return createResponse('error', 'ACCOUNT_CREATE_FAILED')
  }
})
```

## Function Design

- **0-2 parameters max** — Use options object for 3+
- **Explicit return types** on exported functions
- **Pure functions preferred** — Side effects isolated at boundaries
- **Max 50 lines per function** — Extract helpers when exceeded

```typescript
// 3+ params → use options object
function createUser({ name, email, role }: CreateUserOptions): User {}
```

## Code Comments

- Describe **why**, never **what**
- No historical notes (use git blame)
- No TODO without linked issue
- Keep concise — if code needs explanation, simplify the code first

## Rule of Three — Duplication Criteria

| Count | Action                        | Reason                     |
| ----- | ----------------------------- | -------------------------- |
| 1st   | Inline                        | Can't predict future needs |
| 2nd   | Note for potential extraction | Pattern emerging           |
| 3rd   | **Extract**                   | Pattern confirmed          |

**Extract when**: Business logic, validation rules, complex algorithms
**Don't extract when**: Coincidental similarity, test helpers, likely to diverge

## Debugging: 5 Whys

```
Symptom: API returns 500
Why 1: Unhandled null in service → Why 2: DB returned null for user
Why 3: User ID from token is stale → Why 4: Token not invalidated on delete
Why 5: Logout doesn't revoke tokens
Root cause: Missing token revocation on user deletion
```

## Logging

- **Never use `console.log` in production code**
- Use project's structured logger:
  - Electron: `CoreLogger` from mkt-core (`logger.info()`, `logger.error()`)
  - Library: `this.logUpdate()` from `LabsBaseClass` for action progress
- Log with context: include module name, operation, and relevant IDs
- Never log sensitive data (passwords, tokens, API keys)

```typescript
// WRONG
console.log('user created')
console.log(password)

// RIGHT
logger.info('[AccountModel] Account created', { uid: account.uid })
logger.error('[ExcuseAction] Failed:', error as Error)
```

## Verify Commands

> Verify commands: see .claude/rules/implementation.md

## Clean Code Checklist

> TypeScript and error handling items are enforced by `.claude/rules/typescript.md` and the sections above. This checklist covers remaining concerns.

- [ ] No commented-out code
- [ ] No unused imports or variables
- [ ] Naming follows conventions (see `naming-conventions` skill)
- [ ] No `console.log` in production code (see Logging section above)
