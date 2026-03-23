---
name: documentation-standards
description: Documentation types, quality criteria, folder structure, and templates for Node.js / Electron / library projects. Covers README, ADR, Design Doc, API docs, guides, troubleshooting, and changelog.
layer: core
---

# Documentation Standards

## Documentation Folder Structure

All documentation lives in `docs/` with category-based organization:

```
docs/
├── guides/                  # How-to, tutorials, onboarding, coding rules
│   ├── getting-started.md
│   ├── frontend-coding-rules.md
│   └── {topic}-guide.md
│
├── architecture/            # System design, decisions, patterns
│   ├── overview.md          # Architecture overview
│   ├── adr/                 # Architecture Decision Records
│   │   └── ADR-NNNN-{title}.md
│   └── design/              # Feature design documents
│       └── {feature-name}.md
│
├── api/                     # API docs, IPC contracts, interfaces, entities
│   ├── ipc-channels.md      # IPC channel inventory (Electron)
│   ├── entities.md          # Database entity documentation
│   ├── providers.md         # Provider pattern documentation (Library)
│   └── {module}-api.md      # Module API documentation
│
├── troubleshooting/         # Bug fixes, known issues, debugging guides
│   ├── known-issues.md      # Known issues and workarounds
│   └── fix-{issue-name}.md  # Specific bug fix documentation
│
├── plans/                   # Work plans, roadmaps, release plans
│   └── YYYYMMDD-{plan-name}.md
│
└── changelog/               # Release notes, version history
    └── CHANGELOG.md
```

### Folder Purposes

| Folder                 | What goes here                                          | Example                                          |
| ---------------------- | ------------------------------------------------------- | ------------------------------------------------ |
| `guides/`              | How to do X, onboarding, coding standards, tutorials    | `frontend-coding-rules.md`, `getting-started.md` |
| `architecture/`        | System design, ADRs, architecture overview, patterns    | `ADR-0001-use-typeorm.md`, `overview.md`         |
| `architecture/design/` | Feature-level technical design before implementation    | `browser-automation.md`                          |
| `api/`                 | IPC contracts, entity schemas, provider docs, REST APIs | `ipc-channels.md`, `entities.md`                 |
| `troubleshooting/`     | Bug fix records, known issues, debugging steps          | `fix-sqlite-wal-lock.md`, `known-issues.md`      |
| `plans/`               | Implementation plans, release plans, migration plans    | `20260318-auth-refactor.md`                      |
| `changelog/`           | Version history, what changed per release               | `CHANGELOG.md`                                   |

### File Naming Rules

- All files: `kebab-case.md`
- ADRs: `ADR-NNNN-{descriptive-title}.md` (numbered sequentially)
- Plans: `YYYYMMDD-{plan-name}.md` (date-prefixed)
- Fix docs: `fix-{issue-name}.md`
- No spaces in file names
- No special characters or non-ASCII

---

## When to Create Documentation

| Change scope          | Files | Documents needed                        |
| --------------------- | ----- | --------------------------------------- |
| Trivial               | 1-2   | None — code is self-documenting         |
| Small feature         | 3-5   | Design Doc (recommended)                |
| Medium feature        | 6-10  | Design Doc + Work Plan (required)       |
| Large feature         | 10+   | PRD + Design Doc + Work Plan (required) |
| Architecture change   | Any   | ADR (required)                          |
| New library/framework | Any   | ADR (required)                          |
| Bug fix (complex)     | Any   | Troubleshooting doc (recommended)       |
| New IPC channel       | Any   | Update `api/ipc-channels.md`            |
| New entity            | Any   | Update `api/entities.md`                |
| New provider          | Any   | Update `api/providers.md`               |

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

### 6. Troubleshooting Document

**Purpose**: Record how a bug was found, what caused it, and how it was fixed. Prevents repeat debugging.

**Location**: `docs/troubleshooting/fix-{issue-name}.md`

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

#### Known Issues Document

**Location**: `docs/troubleshooting/known-issues.md`

```markdown
# Known Issues

| Issue           | Symptom                         | Workaround  | Status        |
| --------------- | ------------------------------- | ----------- | ------------- |
| SQLite WAL lock | DB writes fail under heavy load | Restart app | Investigating |
| ...             | ...                             | ...         | ...           |
```

---

### 7. Work Plan

**Purpose**: Break implementation into trackable phases.

**Location**: `docs/plans/YYYYMMDD-{plan-name}.md`

**Template**:

```markdown
# Work Plan: <Feature>

## Phase 1: Foundation

- [ ] Task 1: <description>
- [ ] Task 2: <description>

## Phase 2: Core Implementation

- [ ] Task 3: <description>

## Phase 3: Integration

- [ ] Task 4: <description>

## Phase 4: Quality Assurance

- [ ] Lint + type check
- [ ] Test coverage
- [ ] Documentation updated
```

---

### 8. Changelog

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
