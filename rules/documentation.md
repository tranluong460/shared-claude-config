---
paths:
  - 'docs/**'
---

# Documentation Rules

## Folder structure

```
docs/
├── onboarding/          # REQUIRED — developer onboarding (numbered NN-*.md)
├── user-guide/          # REQUIRED — end-user guide (numbered NN-*.md)
├── guides/              # How-to, tutorials (project-dependent)
├── architecture/        # ADRs, design docs
│   ├── adr/             # Project-wide ADRs
│   └── design/          # Feature design docs
├── api/                 # IPC channels, entities, providers
├── fix/                 # Bug fix records
├── plans/               # Work plans — FOLDER per plan, not flat file
│   └── YYYYMMDD-{name}/
│       ├── overview.md
│       ├── business-tdd/{business.md, tdd.md}
│       ├── design/{architecture.md, execution-plan.md, impact-analysis.md, risks.md}
│       └── adr/ADR-NNN-{decision}.md
├── reference/           # Optional — internal reference
└── changelog/           # CHANGELOG.md
```

## File naming

- All: `kebab-case.md`
- ADRs (project-wide): `ADR-NNNN-{title}.md`
- ADRs (inside a plan): `ADR-NNN-{title}.md`
- Plans: `YYYYMMDD-{name}/` — **folder**, never flat `YYYYMMDD-{name}.md`
- Onboarding / user-guide files: `NN-{kebab-case}.md` (numbered for reading order)
- Fix records: `{issue-name}.md` inside `docs/fix/`
- NO spaces, NO .docx

## Required tracks

`docs/onboarding/` and `docs/user-guide/` MUST exist on every project.

- `onboarding/` is multi-file, sequentially numbered, each file links prev/next.
- `user-guide/` is multi-file, sequentially numbered, no internal class names or source paths.
- `README.md` inside each track is an index only — not narrative content.

## When to create docs

- New project / missing tracks → bootstrap `onboarding/` + `user-guide/`
- Architecture change → ADR required (project-wide → `docs/architecture/adr/`, plan-scoped → inside plan folder)
- Medium+ feature (6+ files) → create plan folder under `docs/plans/YYYYMMDD-{name}/`
- Complex bug fix → `docs/fix/{issue-name}.md`
- New IPC channel → update `docs/api/ipc-channels.md`
- New entity → update `docs/api/entities.md`
- New provider → update `docs/api/providers.md`

## Per-file size rule

Keep each individual `.md` file under ~3 pages. This applies **per file**, not per track — onboarding (11 files) and user-guide (10+ files) are large by design; the limit is on each file inside the track.

## Command ↔ Agent output contract (invariant)

When a command delegates to an agent (e.g. `/plan` → `architect`, `/docs` → `doc-manager`, `/audit diagnose` → `debugger`):

- The agent's `## Output Format` / `## Output Formats` section MUST match the command's output rule **verbatim** or transclude it via a section link.
- If the command says "produce a folder", the agent MUST NOT show a template that emits a single file.
- When changing a command's output rule, immediately cross-read every agent it delegates to and update their output sections in the same change.
- `/audit config` verifies this via `skills/audit-config/contract-checks.md` — but static auditing is necessary, not sufficient. Always spot-read after a sync.

This invariant exists because it was violated in the 2026-04-07 session (`commands/refactor-plan.md` — now `commands/plan.md` — mandated folder output while `agents/architect.md` still showed a single-document template) and was only caught by manual review after `/audit config` passed clean.
