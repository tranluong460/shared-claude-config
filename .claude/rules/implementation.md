---
paths:
  - 'src/**'
---

# Implementation Rules

- READ existing similar code BEFORE writing — match patterns exactly
- One logical change at a time — verify typecheck after each step
- Follow existing patterns — consistency > personal preference
- Package manager: `yarn` for install/add/remove — `npm run` for scripts (project convention)

## Verify commands (run before declaring done)

```bash
npm run flint          # format + lint (npm run = script runner)
npm run typecheck      # typecheck node + web
yarn test              # tests (if available)
```

## Pre-commit hook runs automatically:

```
npm run flint → npm run typecheck → git add .
```

## IPC changes = multi-file

Any IPC change MUST update: types → main handler → preload proxy → API endpoint → React hook

## New entity = 5 steps

Entity class → EEntityName enum → AppDataSource → Model object → IPC handlers

## No dead code

Delete unused imports, variables, functions. Git preserves history.
