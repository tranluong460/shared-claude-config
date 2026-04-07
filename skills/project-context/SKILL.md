---
name: project-context
description: Pointer to project-level context. Per Phase 5 consolidation, primary project context lives in the project's root CLAUDE.md (auto-loaded), not in this skill. Read this skill only if CLAUDE.md is missing.
layer: project
---

# Project Context — Pointer

> **Phase 5 consolidation note**: Project-specific tech stack, build commands, conventions, and gotchas now live in the **project's root `CLAUDE.md`** (e.g. `D:\Code\MKT\mkt-browser\CLAUDE.md`), which is auto-loaded by Claude Code on session start. This eliminates the on-demand loading round-trip that was needed when project context was a skill.

## How to use this skill

1. **First**, look for `CLAUDE.md` at the project root. If present, use it as the canonical project context — do not also load this skill.
2. **Only** if `CLAUDE.md` is missing, fall back to whatever skeleton is preserved here.

## Why the move

| Reason | Detail |
|---|---|
| Always-relevant content | Project context is needed every session — auto-load > on-demand load |
| Fewer hops | Skill loading adds metadata scan + read overhead. CLAUDE.md is in the entry context. |
| Edit ergonomics | CLAUDE.md is the standard "house rules" location per community 2026 best practice |

## Skeleton (fallback only — keep CLAUDE.md as source of truth)

If you need to bootstrap a new CLAUDE.md, use this minimum structure (~80-120 lines):

```markdown
# <Project Name> — Project Entry Context

## What
<1-line description, package name, version>

## Stack
| Layer | Technology |

## Build & Dev Commands
| Action | Command |

## Architecture (high-level)
\`\`\`
src/
├── ...
\`\`\`

## Critical Conventions (do not skip)
- <link to .claude/rules/*.md for each>

## Known Gotchas
- <traps that wasted time before>

## Self-Improvement Loop
- Lessons: .claude/memory/lessons.md
- Plans: docs/plans/YYYYMMDD-{name}/

## Workflow Commands
- /audit, /plan, /implement, /test, /docs, /review, /reflect
```

## Related

- `.claude/rules/project-detection.md` — heuristics to detect project type
- Project root `CLAUDE.md` — the actual context
