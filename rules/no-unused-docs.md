---
paths:
  - .claude/**
---

# No Unused Documentation (always active)

> Self-protection rule for the `.claude/` system. Run `/audit-docs` to verify.

## Rule

Every document in `.claude/` MUST be referenced by at least one of:

- A command (in `commands/`)
- An agent (in `agents/`)
- `paths:` frontmatter (for auto-injection)

## Enforcement

- If a document has NONE of the above → it MUST be attached to a relevant command/agent OR deleted
- Passive documents (only `paths:` frontmatter) are acceptable for "cách code" rules (naming, formatting, typescript)
- Critical methodology/logic rules MUST be explicitly referenced by at least one command AND one agent
- Run `/audit-docs` periodically to detect violations

## Classification

| Rule type                               | Minimum integration                  |
| --------------------------------------- | ------------------------------------ |
| Code style (naming, formatting)         | `paths:` frontmatter only = OK       |
| Logic/methodology (testing-methodology) | `paths:` + command + agent reference |
| Error reference (error-patterns)        | `paths:` + command reference         |
| Architecture (electron, ipc)            | `paths:` + skill reference           |
