---
description: Generate documentation for specified code — README, guides, API docs, design docs, ADRs, troubleshooting, or changelog
category: execute
mutates: true
consumes: [source-code]
produces: [documentation]
result_states: [success, validation_failed, blocked, execution_error]
next_on_result:
  success: [audit-docs]
  validation_failed: [diagnose]
  blocked: []
  execution_error: [diagnose]
---

You are executing the `/generate-docs` command.

## Input

Target: $ARGUMENTS (doc type + optional scope)

## Workflow

### Step 1: Load Skills

Read and apply:

- `.claude/skills/documentation-standards/SKILL.md`
- `.claude/skills/project-context/SKILL.md` (if filled in)

### Step 2: Determine Doc Type

Parse the input to decide what to generate:

| Input              | Doc Type                             | Output Location                              |
| ------------------ | ------------------------------------ | -------------------------------------------- |
| `readme`           | README.md                            | Project root                                 |
| `guide <topic>`    | Guide / tutorial / how-to            | `docs/guides/{topic}-guide.md`               |
| `adr <decision>`   | Architecture Decision Record         | `docs/architecture/adr/ADR-NNNN-{title}.md`  |
| `design <feature>` | Feature design document              | `docs/architecture/design/{feature-name}.md` |
| `overview`         | Architecture overview                | `docs/architecture/overview.md`              |
| `api <module>`     | API / module documentation           | `docs/api/{module}-api.md`                   |
| `ipc`              | IPC channel reference (Electron)     | `docs/api/ipc-channels.md`                   |
| `entities`         | Database entity reference (Electron) | `docs/api/entities.md`                       |
| `providers`        | Provider pattern reference (Library) | `docs/api/providers.md`                      |
| `fix <issue>`      | Bug fix / troubleshooting record     | `docs/troubleshooting/fix-{issue-name}.md`   |
| `changelog`        | Version changelog                    | `docs/changelog/CHANGELOG.md`                |
| `plan <name>`      | Work / implementation plan           | `docs/plans/YYYYMMDD-{plan-name}.md`         |
| `<file-path>`      | JSDoc for public APIs in file        | Inline in source file                        |

### Step 3: Detect Project Type

> Project type detection: see `.claude/rules/project-detection.md`

After detection, apply project-specific extra doc types:
- **Electron**: `ipc`, `entities`, `guide`
- **Library**: `providers`, `api`

### Step 4: Delegate to Agent

Delegate to the **doc-writer** agent with full context from Steps 1-3.
The agent follows its complete process defined in `.claude/agents/doc-writer.md`:

1. Analyze project (structure, metadata, existing docs)
2. Generate documentation using skill templates
3. Write to correct location per doc type

### Step 5: Report

```markdown
## Documentation Generated

### Files Created/Updated

| File                       | Type          | Status  |
| -------------------------- | ------------- | ------- |
| `docs/guides/{name}.md`    | Guide         | Created |

### Remaining Gaps

- <what documentation is still needed>

### Suggested Follow-ups

- <related docs that should be created>
```

## Notes

- Always check existing docs before generating — update, don't duplicate
- Keep docs under 3 pages — split large docs into multiple files
- Focus on "why" and "how", not "what"
- Include working code examples that compile
- No secrets or credentials in documentation
