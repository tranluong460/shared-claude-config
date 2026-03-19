---
paths:
  - 'src/providers/**'
  - 'src/core/**'
  - 'src/interfaces/**'
---

# Provider Pattern Rules (base-factory)

## New provider structure (MUST follow exactly):

```
providers/{name}/
├── index.ts          → export function register() { LabsProviderRegistry.register(...) }
├── factory.ts        → class {Name}Factory implements ILabsProviderFactory
├── provider.ts       → class {Name}Provider implements I{Name}Provider
└── services/
    ├── index.ts      → export *
    └── actions/
        ├── index.ts  → export *
        └── action-{name}.ts → extends LabsBaseClass
```

## Action rules

- MUST extend `LabsBaseClass`
- Constructor: `super(payload, '{provider}.action_{name}')`
- Progress: `this.logUpdate(key, params)` — NEVER console.log
- Entry: `public async start(): Promise<void>`

## New provider checklist

1. Add to `EnumLabsProvider` enum
2. Define `I{Name}Provider` interface
3. Add to `ProviderTypeMap` + `PayloadConfigMap`
4. Create directory structure above
5. Add test in `test/provider.test.ts`
6. Run: `yarn test && yarn build`

## Barrel exports

Every directory MUST have `index.ts` with `export *` from sub-files.
