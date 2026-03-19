---
description: Generate documentation for specified code — README, guides, API docs, design docs, ADRs, troubleshooting, or changelog
---

You are executing the `/generate-docs` command.

## Input

Target: $ARGUMENTS (doc type + optional scope)

## Workflow

### Step 1: Load Skills

Read and apply:

- `.claude/skills/documentation-standards/SKILL.md`

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
| `known-issues`     | Known issues list                    | `docs/troubleshooting/known-issues.md`       |
| `changelog`        | Version changelog                    | `docs/changelog/CHANGELOG.md`                |
| `plan <name>`      | Work / implementation plan           | `docs/plans/YYYYMMDD-{plan-name}.md`         |
| `<file-path>`      | JSDoc for public APIs in file        | Inline in source file                        |

### Step 3: Ensure Folder Structure

> Folder structure and file naming: see `.claude/rules/documentation.md`

### Step 4: Analyze Code

Act as the **doc-writer** agent (`.claude/agents/doc-writer.md`).

Read and analyze:

```
# Project metadata
package.json          → name, version, scripts, dependencies
src/                  → module structure

# Existing docs (avoid duplication)
docs/**/*.md          → what already exists
README.md             → current state
```

### Step 5: Detect Project Type

> Project type detection: see `.claude/rules/project-detection.md`

After detection, apply project-specific extra doc types:
- **Electron**: `ipc`, `entities`, `guide`
- **Library**: `providers`, `api`
- **Server**: `api`, `guide`

### Step 6: Generate Documentation

Follow the templates from the documentation-standards skill.

#### For README

1. Read `package.json` for name, version, description, scripts
2. Scan `src/` for project structure
3. Check existing README — preserve custom sections
4. Generate with all required sections

#### For Guide

1. Understand the topic scope
2. Write step-by-step instructions with code examples
3. Include prerequisites and common pitfalls
4. Cross-reference related guides

#### For ADR

1. Understand the decision context
2. Research alternatives (3+ options)
3. Generate ADR with pros/cons comparison
4. Include consequences and trade-offs
5. Auto-number: find last ADR number and increment

#### For Design Doc

1. Read the feature's source code
2. Analyze architecture, data flow, integration points
3. For Electron: include IPC changes table
4. For Library: include provider changes table
5. Include acceptance criteria and test strategy

#### For API / IPC Channels (Electron)

1. Scan `src/main/ipc/` for all IPC handlers
2. Scan `src/preload/ipc/` for preload proxies
3. Read type definitions for args and return types
4. Generate channel reference table per domain
5. Mark sync status (handler ↔ proxy)

#### For Entities (Electron)

1. Scan `src/main/database/entities/` for TypeORM entities
2. Read each entity: columns, types, relations, constraints
3. Generate entity reference with column tables
4. Include relationship diagram (mermaid)

#### For Providers (Library)

1. Scan `src/providers/` for all providers
2. Read factory, provider, and action files
3. Generate provider reference with usage examples
4. Include payload types and configuration

#### For Troubleshooting / Fix

1. Document the symptom (what was observed)
2. Document root cause (5 Whys if needed)
3. Document the solution (what was changed)
4. List files modified
5. Add prevention guidance

#### For Changelog

1. Read `git log` for version tags and commit messages
2. Group changes by: Added, Changed, Fixed, Removed
3. Follow Keep a Changelog format
4. Read `package.json` for current version

#### For Work Plan

1. Read the feature/task description
2. Break into phases: Foundation → Core → Integration → QA
3. Create checkable task items
4. Date-prefix the file name with today's date

### Step 7: Write Output

Write to the correct location per doc type (see Step 2 table). File naming per `.claude/rules/documentation.md`.

### Step 8: Report

```markdown
## Documentation Generated

### Files Created/Updated

| File                       | Type          | Status  |
| -------------------------- | ------------- | ------- |
| `docs/guides/{name}.md`    | Guide         | Created |
| `docs/api/ipc-channels.md` | API Reference | Updated |

### Sections Covered

- <list of documentation sections>

### Remaining Gaps

- <what documentation is still needed>

### Suggested Follow-ups

- <related docs that should be created>
```

## Notes

- Always check existing docs before generating — update, don't duplicate
- Keep docs under 3 pages — split large docs into multiple files
- Focus on "why" and "how", not "what" (code already shows "what")
- Include working code examples that compile
- No secrets or credentials in documentation
- Convert any `.docx` files to `.md` when encountered
- Use mermaid diagrams for architecture visualization
- Cross-reference related docs with relative links
