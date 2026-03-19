---
paths:
  - 'docs/**'
---

# Documentation Rules

## Folder structure

```
docs/
├── guides/              # How-to, tutorials
├── architecture/        # ADRs, design docs
│   ├── adr/
│   └── design/
├── api/                 # IPC channels, entities, providers
├── troubleshooting/     # Bug fixes, known issues
├── plans/               # Work plans (YYYYMMDD-name.md)
└── changelog/           # CHANGELOG.md
```

## File naming

- All: `kebab-case.md`
- ADRs: `ADR-NNNN-{title}.md`
- Plans: `YYYYMMDD-{name}.md`
- Fixes: `fix-{issue}.md`
- NO spaces, NO .docx

## When to create docs

- Architecture change → ADR required
- 6+ files changed → Design Doc + Work Plan
- Complex bug fix → `docs/troubleshooting/fix-{name}.md`
- New IPC channel → update `docs/api/ipc-channels.md`
