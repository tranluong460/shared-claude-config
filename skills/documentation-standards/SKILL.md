---
name: documentation-standards
description: Documentation types, quality criteria, folder structure, and templates for Node.js / Electron / library projects. Covers required onboarding + user-guide tracks, README, ADR, Design Doc, API docs, guides, plan folders, fix records, and changelog.
layer: core
---

# Documentation Standards

## Documentation Folder Structure

All documentation lives in `docs/` with category-based organization. Two tracks are **required** on every project; the rest are project-dependent.

```
docs/
├── onboarding/              # REQUIRED — developer onboarding track (multi-file)
│   ├── README.md            # Index + reading order
│   ├── 00-start-here.md
│   ├── 01-project-overview.md
│   ├── 02-system-architecture.md
│   ├── 03-project-structure.md
│   ├── 04-core-modules.md
│   ├── 05-main-workflows.md
│   ├── 06-development-workflow.md
│   ├── 07-how-to-add-feature.md
│   ├── 08-how-to-modify-safely.md
│   ├── 09-debugging-guide.md
│   └── 10-common-pitfalls.md
│
├── user-guide/              # REQUIRED — end-user guide track (multi-file)
│   ├── README.md            # Index
│   ├── 01-introduction.md
│   ├── 02-getting-started.md
│   ├── 03-{core-concept}.md
│   ├── 04-configuration.md
│   ├── 05..NN-{feature-area}.md   # Adaptive feature-area files
│   ├── NN-error-handling.md
│   └── NN-development-guide.md    # Optional: power users / extension authors
│
├── guides/                  # Project-dependent — how-to, tutorials, coding rules
│   └── {topic}-guide.md
│
├── architecture/            # Project-wide system design, decisions, patterns
│   ├── overview.md
│   ├── adr/                 # Project-wide ADRs
│   │   └── ADR-NNNN-{title}.md
│   └── design/              # Feature design documents
│       └── {feature-name}.md
│
├── api/                     # API docs, IPC contracts, entity/provider schemas
│   ├── ipc-channels.md      # IPC channel inventory (Electron)
│   ├── entities.md          # Database entity documentation
│   ├── providers.md         # Provider pattern documentation (Library)
│   └── {module}-api.md      # Module API documentation
│
├── fix/                     # Bug fix records
│   ├── README.md            # Index of known issues
│   └── {issue-name}.md      # Specific fix record
│
├── plans/                   # Work plans — FOLDER per plan, not flat file
│   ├── README.md            # Plan index
│   └── YYYYMMDD-{plan-name}/
│       ├── overview.md
│       ├── business-tdd/
│       │   ├── business.md
│       │   └── tdd.md
│       ├── design/
│       │   ├── architecture.md
│       │   ├── execution-plan.md
│       │   ├── impact-analysis.md
│       │   └── risks.md
│       └── adr/
│           └── ADR-NNN-{decision}.md
│
├── reference/               # Optional — internal reference material
│
└── changelog/               # Release notes, version history
    └── CHANGELOG.md
```

### Folder Purposes

| Folder                 | Required? | What goes here                                          | Example                                        |
| ---------------------- | --------- | ------------------------------------------------------- | ---------------------------------------------- |
| `onboarding/`          | **Yes**   | Developer onboarding track — numbered sequential files  | `00-start-here.md`, `07-how-to-add-feature.md` |
| `user-guide/`          | **Yes**   | End-user guide track — no source paths or class names   | `02-getting-started.md`, `05-smart-actions.md` |
| `guides/`              | No        | How-to recipes, coding standards, tutorials             | `frontend-coding-rules.md`                     |
| `architecture/`        | No        | System design, architecture overview                    | `overview.md`                                  |
| `architecture/adr/`    | No        | Project-wide ADRs                                       | `ADR-0001-use-typeorm.md`                      |
| `architecture/design/` | No        | Feature-level technical design before implementation    | `browser-automation.md`                        |
| `api/`                 | No        | IPC contracts, entity schemas, provider docs, REST APIs | `ipc-channels.md`, `entities.md`               |
| `fix/`                 | No        | Bug fix records, known issues, debugging steps          | `socks5-proxy-auth-fix-report.md`              |
| `plans/`               | No        | Implementation plans — one **folder** per plan          | `20260320-smart-waiting-mechanism-refactor/`   |
| `reference/`           | No        | Internal reference material (downloads, constants, ...) | `download.md`, `lifecycle.md`                  |
| `changelog/`           | No        | Version history, what changed per release               | `CHANGELOG.md`                                 |

### File Naming Rules

- All files: `kebab-case.md`
- Onboarding / user-guide files: `NN-{kebab-case}.md` — numbered prefix locks reading order
- ADRs (project-wide): `ADR-NNNN-{descriptive-title}.md`
- ADRs (inside a plan): `ADR-NNN-{title}.md` (scoped to plan)
- Plans: `YYYYMMDD-{plan-name}/` — **folder**, never a flat `.md` file
- Fix records: `{issue-name}.md` inside `docs/fix/`
- No spaces in file names
- No special characters or non-ASCII
- **Per-file size rule**: keep each individual file under ~3 pages. This applies per file, not per track — `onboarding/` and `user-guide/` are large by design.

---

## When to Create Documentation

| Change scope                | Files | Documents needed                                    |
| --------------------------- | ----- | --------------------------------------------------- |
| **Project bootstrap**       | —     | `onboarding/` + `user-guide/` tracks (**required**) |
| Trivial                     | 1-2   | None — code is self-documenting                     |
| Small feature               | 3-5   | Design Doc (recommended)                            |
| Medium feature              | 6-10  | Plan **folder** under `docs/plans/` (required)      |
| Large feature               | 10+   | Plan folder + project-wide ADR (required)           |
| Architecture change         | Any   | ADR (required)                                      |
| New library/framework       | Any   | ADR (required)                                      |
| Bug fix (complex)           | Any   | Fix record under `docs/fix/` (recommended)          |
| New IPC channel             | Any   | Update `api/ipc-channels.md`                        |
| New entity                  | Any   | Update `api/entities.md`                            |
| New provider                | Any   | Update `api/providers.md`                           |
| New user-visible feature    | Any   | Add a file under `user-guide/`                      |
| New developer-facing module | Any   | Update `onboarding/04-core-modules.md`              |

---

## Document Types & Templates

### 1. README.md (Project Root)

**Purpose**: First thing a developer reads. "What is this? How do I run it?"

**Location**: Project root (`README.md`)

**Required sections**:

- Project name and one-line description
- Prerequisites (Node version, tools)
- Getting started (install, configure, run)
- Project structure overview
- Available scripts
- Testing instructions

**Template**:

```markdown
# <Project Name>

> <One-line description>

## Features

- Feature 1: brief description
- Feature 2: brief description

## Prerequisites

- Node.js >= <version>
- <other requirements>

## Getting Started

### Installation

\`\`\`bash
yarn install
\`\`\`

### Configuration

Copy `.env.example` to `.env` and fill in values.

### Running

\`\`\`bash
yarn dev # Development
yarn build # Production build
\`\`\`

## Project Structure

\`\`\`
src/
├── main/ # Main process (Electron)
├── preload/ # Preload scripts
├── renderer/ # React UI
└── ...
\`\`\`

## Scripts

| Script  | Description              |
| ------- | ------------------------ |
| `dev`   | Start development server |
| `build` | Build for production     |
| `test`  | Run test suite           |
| `lint`  | Lint and fix code        |
```

---

### 2. Guide Document

**Purpose**: Teach how to do something. Step-by-step instructions.

**Location**: `docs/guides/{topic}-guide.md`

**Template**:

```markdown
# Guide: <Topic>

## Overview

What this guide covers and who it's for.

## Prerequisites

What the reader needs to know or have installed.

## Steps

### Step 1: <Title>

<Instructions with code examples>

### Step 2: <Title>

<Instructions>

## Common Pitfalls

- <Pitfall 1>: <How to avoid>

## Related

- [Other guide](../guides/other.md)
```

---

### 3. ADR (Architecture Decision Record)

**Purpose**: Record **why** a technical decision was made.

**Location**: `docs/architecture/adr/ADR-NNNN-{title}.md`

**When required**:

- New external dependency introduced
- Architecture pattern changed
- Database/storage technology changed
- API protocol changed
- Major refactoring approach selected

**Template**:

```markdown
# ADR-NNNN: <Title>

## Status

Proposed | Accepted | Deprecated | Superseded

## Context

What is the problem or situation?

## Decision

What was decided?

## Options Considered

| Option | Pros | Cons |
| ------ | ---- | ---- |
| A      | ...  | ...  |
| B      | ...  | ...  |
| C      | ...  | ...  |

## Consequences

What are the results of this decision?

## References

Links to relevant resources
```

---

### 4. Design Document

**Purpose**: Define **how** a feature will be implemented technically.

**Location**: `docs/architecture/design/{feature-name}.md`

**When required**: 3+ files changed, new module, cross-cutting concern

**Template**:

```markdown
# Design: <Feature Name>

## Overview

What this feature does and why.

## Technical Approach

How it will be implemented.

## Data Model

Entities, types, schemas involved.

## Integration Points

What existing code is affected.

### IPC Changes (Electron)

| Channel | Direction | Payload | Response |
| ------- | --------- | ------- | -------- |

### Provider Changes (Library)

| Provider | Action | Input | Output |
| -------- | ------ | ----- | ------ |

## Acceptance Criteria

- [ ] AC1: <measurable criterion>
- [ ] AC2: ...

## Test Strategy

What tests will be written.
```

---

### 5. API Documentation

**Purpose**: Document contracts, IPC channels, entities, providers for consumers.

**Location**: `docs/api/{module}-api.md`

#### IPC Channel Documentation (Electron)

**Location**: `docs/api/ipc-channels.md`

```markdown
# IPC Channel Reference

## Account

| Channel               | Args                    | Return                     | Description            |
| --------------------- | ----------------------- | -------------------------- | ---------------------- |
| `account_create`      | `ICreateAccountPayload` | `IMainResponse<Account>`   | Create new account     |
| `account_readByField` | `IReadByFieldPayload`   | `IMainResponse<Account[]>` | Read accounts by field |

## Setting

| Channel          | Args                    | Return                | Description         |
| ---------------- | ----------------------- | --------------------- | ------------------- |
| `setting_update` | `IUpdateSettingPayload` | `IMainResponse<void>` | Update app settings |
```

#### Entity Documentation (Electron)

**Location**: `docs/api/entities.md`

```markdown
# Database Entities

## Account

| Column   | Type            | Nullable | Description          |
| -------- | --------------- | -------- | -------------------- |
| uuid     | string (PK)     | No       | Auto-generated UUID  |
| uid      | string (unique) | No       | Social media user ID |
| password | string          | Yes      | Account password     |
| category | Category (FK)   | Yes      | Category relation    |
```

#### Provider Documentation (Library)

**Location**: `docs/api/providers.md`

```markdown
# Provider Reference

## Available Providers

| Provider   | Type                          | Description        |
| ---------- | ----------------------------- | ------------------ |
| Automated  | `EnumLabsProvider.AUTOMATED`  | Browser automation |
| Scripted   | `EnumLabsProvider.SCRIPTED`   | Script-based       |
| Direct API | `EnumLabsProvider.DIRECT_API` | Direct API calls   |

## Usage

\`\`\`typescript
const provider = await LabsProviderFacade.getProvider({
type: EnumLabsProvider.AUTOMATED,
keyTarget: 'target-id',
logUpdate: myLogFn,
})
await provider.start()
\`\`\`
```

---

### 6. Fix Record

**Purpose**: Record how a bug was found, what caused it, and how it was fixed. Prevents repeat debugging.

**Location**: `docs/fix/{issue-name}.md`

**When to create**: Complex bugs that took significant effort to diagnose.

**Template**:

```markdown
# Fix: <Issue Title>

## Symptom

What the user/developer observed.

## Root Cause

What actually caused the issue. Use 5 Whys if needed.

## Solution

What was changed to fix it.

### Files Modified

- `<file>`: <what changed>

## Prevention

How to prevent this from happening again.

## Related

- Issue: #<number>
- Commit: <hash>
```

#### Fix Index

**Location**: `docs/fix/README.md`

```markdown
# Fix Records

| File                              | Symptom             | Status   |
| --------------------------------- | ------------------- | -------- |
| `socks5-proxy-auth-fix-report.md` | SOCKS5 auth failing | Resolved |
| ...                               | ...                 | ...      |
```

---

### 7. Plan Folder

**Purpose**: Break a non-trivial implementation into business requirements, tests, architecture, execution phases, impact, risks, and scoped decisions. Plans are **folders**, never a single file.

**Location**: `docs/plans/YYYYMMDD-{plan-name}/`

**When to create**: Medium+ feature (6+ files affected), refactor, migration.

**Folder skeleton**:

```
docs/plans/YYYYMMDD-{plan-name}/
├── overview.md
├── business-tdd/
│   ├── business.md
│   └── tdd.md
├── design/
│   ├── architecture.md
│   ├── execution-plan.md
│   ├── impact-analysis.md
│   └── risks.md
└── adr/
    └── ADR-001-{first-decision}.md
```

#### 7.1 `overview.md` template

```markdown
# Plan: <Plan Name>

> Date: YYYY-MM-DD · Owner: <name> · Status: Draft | Active | Done

## Summary

One paragraph: what, why, for whom.

## Goals

- Goal 1
- Goal 2

## Non-goals

- What this plan explicitly does NOT cover.

## Sub-documents

- [Business](./business-tdd/business.md) — requirements, acceptance
- [TDD](./business-tdd/tdd.md) — test cases before code
- [Architecture](./design/architecture.md) — target module layout
- [Execution Plan](./design/execution-plan.md) — phased breakdown
- [Impact Analysis](./design/impact-analysis.md) — blast radius
- [Risks](./design/risks.md) — risks + rollback
- [ADRs](./adr/) — scoped decisions
```

#### 7.2 `business-tdd/business.md` template

```markdown
# Business Requirements

## Problem

What user / business pain does this solve?

## Users

Who is affected, in what context.

## Acceptance Criteria

- [ ] AC1: <measurable>
- [ ] AC2: ...

## Out of Scope

- Things intentionally excluded
```

#### 7.3 `business-tdd/tdd.md` template

```markdown
# Test-Driven Design

Test cases written **before** code. Each case must be executable or reviewable.

## Happy Path

- `test_<case>`: given <X>, when <Y>, then <Z>

## Edge Cases

- `test_<edge>`: ...

## Failure Modes

- `test_<error>`: given <bad input>, should <error response>

## Regression Guards

- Existing behavior that must keep working
```

#### 7.4 `design/architecture.md` template

```markdown
# Target Architecture

## Current State

Brief summary of what exists today (link to `docs/architecture/overview.md` if present).

## Target State

Modules, classes, interfaces after this plan lands.

## Diagram

\`\`\`mermaid
graph TD
A[Caller] --> B[New Facade]
B --> C[Existing Service]
\`\`\`

## Key Interfaces

\`\`\`typescript
interface NewThing {
doIt(input: Input): Promise<Output>
}
\`\`\`
```

#### 7.5 `design/execution-plan.md` template

```markdown
# Execution Plan

## Phase 1: Foundation

- [ ] Task 1.1: <description>
- [ ] Task 1.2: <description>

## Phase 2: Core Implementation

- [ ] Task 2.1: <description>

## Phase 3: Integration

- [ ] Task 3.1: <description>

## Phase 4: Quality Assurance

- [ ] Lint + type check
- [ ] Test coverage ≥ target
- [ ] Docs updated (`onboarding/`, `user-guide/`, changelog)
```

#### 7.6 `design/impact-analysis.md` template

```markdown
# Impact Analysis

## Affected Files

| File      | Change Type | Risk         |
| --------- | ----------- | ------------ |
| `src/...` | Modify      | Low/Med/High |

## Blast Radius

- Modules directly touched: ...
- Modules indirectly affected (imports, IPC, events): ...

## Business Logic at Risk

- <critical flow> → protected by <test / guard>
```

#### 7.7 `design/risks.md` template

```markdown
# Risks & Mitigation

| Risk | Likelihood   | Impact       | Mitigation |
| ---- | ------------ | ------------ | ---------- |
| ...  | Low/Med/High | Low/Med/High | ...        |

## Rollback Strategy

How to revert this plan if it fails in production.
```

#### 7.8 `adr/ADR-NNN-{decision}.md` template

Plan-scoped ADRs follow the same template as project-wide ADRs (see §3) but numbered locally (ADR-001, ADR-002, ...) and scoped to the plan. Project-wide decisions still live in `docs/architecture/adr/`.

---

### 8. Onboarding Track (REQUIRED)

**Purpose**: Teach new developers the project end-to-end, in reading order.

**Location**: `docs/onboarding/`

**File list** (all required):

| File                         | Purpose                                          |
| ---------------------------- | ------------------------------------------------ |
| `README.md`                  | Index + reading order (not narrative)            |
| `00-start-here.md`           | Entry point, prerequisites, how to use the track |
| `01-project-overview.md`     | What the product does, who uses it, why          |
| `02-system-architecture.md`  | High-level architecture: processes, layers, flow |
| `03-project-structure.md`    | Folder walkthrough with purposes                 |
| `04-core-modules.md`         | Key modules and responsibilities                 |
| `05-main-workflows.md`       | Critical runtime flows end-to-end                |
| `06-development-workflow.md` | Install, run, build, test, debug                 |
| `07-how-to-add-feature.md`   | Recipe for adding a new feature                  |
| `08-how-to-modify-safely.md` | Impact analysis + safe-change rules              |
| `09-debugging-guide.md`      | Common bugs, tools, logs                         |
| `10-common-pitfalls.md`      | Traps to avoid                                   |

**Per-file skeleton**:

```markdown
# <NN>. <Title>

> Prev: [<prev file>](./NN-prev.md) · Next: [<next file>](./NN-next.md)

## What you will learn

- Bullet 1
- Bullet 2

## <Main content sections>

...

## Try it

A small hands-on exercise the reader can run in 5 minutes.

## Key takeaways

- ...

---

Next up: [<next title>](./NN-next.md)
```

**Rules**:

- Files are numbered `NN-kebab-case.md` — reading order is explicit.
- Every file has prev/next links at top AND bottom.
- Free to link to `src/` paths, ADRs, design docs.
- Keep each file under ~3 pages.

---

### 9. User Guide Track (REQUIRED)

**Purpose**: Teach end users how to use the product. Not developers.

**Location**: `docs/user-guide/`

**File list** (first 4 fixed, feature-area files adaptive):

| File                       | Purpose                               | Required?            |
| -------------------------- | ------------------------------------- | -------------------- |
| `README.md`                | Index                                 | Yes                  |
| `01-introduction.md`       | What the product is, who it's for     | Yes                  |
| `02-getting-started.md`    | Install, first launch, first success  | Yes                  |
| `03-{core-concept}.md`     | Core domain concept from user view    | Yes                  |
| `04-configuration.md`      | Settings and options                  | Yes                  |
| `05..NN-{feature-area}.md` | One per feature area (adaptive count) | One per feature area |
| `NN-error-handling.md`     | How errors surface and recover        | Yes                  |
| `NN-development-guide.md`  | Power users / extension authors       | Optional             |

**Per-file skeleton**:

```markdown
# <Feature / Section>

> For: <who should read this>

## What this does

Plain-language description.

## How to use it

Step-by-step, with screenshots.

1. Step one
2. Step two

## Options

| Option | Default | Effect |
| ------ | ------- | ------ |
| ...    | ...     | ...    |

## Troubleshooting

- **Problem**: <symptom> → **Fix**: <what user should do>

## See also

- [<related user-guide file>](./NN-related.md)
```

**Rules**:

- NO source file paths (`src/...`), NO internal class names, NO IPC channel names.
- Screenshots live next to the file that references them.
- Feature-area count adapts to the project — do not pad to a fixed number.
- Keep each file under ~3 pages.

---

### 10. Reference Document

**Purpose**: Capture internal reference material that does not fit onboarding (not narrative) or user-guide (not end-user facing) — e.g. constants tables, provider catalogs, browser detection matrices, lifecycle states.

**Location**: `docs/reference/{topic}.md`

**When to create**: You need a lookup table or catalog that's cited from multiple places (code comments, ADRs, other docs).

**Template**:

```markdown
# Reference: <Topic>

> Lookup / catalog document. Keep factual, minimize prose.

## Overview

One paragraph: what this reference covers and when to consult it.

## <Catalog / Table>

| Key | Value | Notes |
| --- | ----- | ----- |
| ... | ...   | ...   |

## Related

- Source of truth: `src/.../<file>.ts`
- Consumers: `docs/onboarding/NN-...md`, `docs/api/...md`
```

**Rules**:

- Reference docs must cite the source of truth in code (file path) so they can be verified.
- Prefer tables over prose.
- If the content is a how-to, it belongs in `guides/`, not `reference/`.
- If the content is narrative onboarding, it belongs in `onboarding/`, not `reference/`.

---

### 11. Changelog

**Purpose**: Track what changed per version for users and developers.

**Location**: `docs/changelog/CHANGELOG.md`

**Template**:

```markdown
# Changelog

## [1.2.0] - 2026-03-18

### Added

- New feature X

### Changed

- Updated behavior of Y

### Fixed

- Bug where Z happened

## [1.1.4] - 2026-03-15

### Fixed

- ...
```

---

## Code Documentation (JSDoc)

### When Required

- Exported library functions (public API)
- Functions with complex parameters or return types
- Functions with non-obvious side effects
- Functions that throw specific errors

### When NOT Needed

- Internal/private functions with clear names
- Simple CRUD operations
- Test code
- One-line utility functions

### Example

```typescript
// DO: Complex public API
/**
 * Retries the operation with exponential backoff.
 * Delay doubles each attempt: 100ms, 200ms, 400ms...
 *
 * @param maxRetries - Maximum number of retry attempts (default: 3)
 * @throws {TimeoutError} When all retries are exhausted
 */
export async function withRetry<T>(fn: () => Promise<T>, maxRetries = 3): Promise<T> {}

// DON'T: Obvious function
/** Gets user by ID */ // <-- Redundant
export function getUserById(id: string): User {}
```

---

## Documentation Quality Checklist

- [ ] README has getting started instructions that work out of the box
- [ ] All ADRs have Status, Context, Decision, Consequences
- [ ] Design Docs have measurable Acceptance Criteria
- [ ] API docs match actual implementation
- [ ] No stale documentation (matches current code)
- [ ] Examples compile and run correctly
- [ ] No secrets or credentials in documentation
- [ ] All files in correct category folder
- [ ] File names use kebab-case (no spaces, no special chars)

## Documentation Anti-Patterns

| Anti-Pattern                 | Problem               | Fix                                 |
| ---------------------------- | --------------------- | ----------------------------------- |
| Documenting "what" not "why" | Redundant with code   | Focus on rationale                  |
| 100-page design doc          | Nobody reads it       | Keep under 3 pages                  |
| Docs written after release   | Already outdated      | Write docs during implementation    |
| Copy-paste README            | Doesn't match project | Write from scratch for each project |
| No versioning on APIs        | Breaking changes      | Semver + changelog                  |
| Docs outside `docs/` folder  | Hard to find          | Move to correct category folder     |
| Spaces in file names         | CLI/git issues        | Use kebab-case                      |
| `.docx` in repo              | Can't diff/review     | Convert to `.md`                    |
