---
paths:
  - 'src/main/database/**'
---

# Database Rules

## Entity

- File: `{Entity}Entity.ts` — class extends `CommonEntity`
- Decorator: `@Entity(EEntityName.{name})`
- PK: `@PrimaryGeneratedColumn('uuid')`
- Columns: `snake_case` names — `is_auto`, `created_at`
- New columns: add as `nullable` first, migrate data, then make required
- Register in `AppDataSource.ts` entities array

## Model

- File: `{Entity}.ts` in `models/` — export `{Entity}Model` object
- Every method returns `Promise<IMainResponse<T>>`
- Every method has `try-catch` with `logger.error()` + `createResponse()`
- Batch operations: use `chunk()` for large datasets
- Access: use `{entity}Repo()` and `{entity}QB()` helper functions

## Response pattern

```typescript
return createResponse('message_key', 'success', { data })
return createResponse('error_key', 'error')
```
