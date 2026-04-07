---
description: Generate documentation for specified code — onboarding + user-guide tracks, plan folders, README, guides, API docs, design docs, ADRs, fix records, or changelog
category: execute
mutates: true
consumes: [source-code]
produces: [documentation]
result_states: [success, validation_failed, blocked, execution_error]
next_on_result:
  success: [audit-config]
  validation_failed: [diagnose]
  blocked: []
  execution_error: [diagnose]
---

You are executing the `/generate-docs` command.

## Input

Target: $ARGUMENTS (doc type, optionally followed by file/module path)

Examples:

- `/generate-docs onboarding` — developer onboarding track (required)
- `/generate-docs user-guide` — end-user guide track (required)
- `/generate-docs plan smart-waiting-refactor` — full plan folder with overview + ADRs + business-tdd + design
- `/generate-docs API src/main/ipcs` — API reference for IPC handlers
- `/generate-docs ADR` — standalone Architecture Decision Record
- `/generate-docs fix src/system/workers/sync` — fix record
- `/generate-docs changelog` — changelog from recent commits

Doc types:

- **Required (every project)**: `onboarding`, `user-guide`
- **Project-dependent**: `readme`, `plan`, `adr`, `design`, `overview`, `api`, `ipc`, `entities`, `providers`, `guide`, `fix`, `changelog`

## Workflow

### Step 1: Load Skills

Read and apply:

- `.claude/skills/documentation-standards/SKILL.md`
- `.claude/skills/project-context/SKILL.md` (if filled in)

### Step 2: Determine Doc Type

Parse the input to decide what to generate:

#### Required doc tracks (every project must have these)

| Input         | Doc Type                     | Output Location     |
| ------------- | ---------------------------- | ------------------- |
| `onboarding`  | Developer onboarding track   | `docs/onboarding/`  |
| `user-guide`  | End-user usage guide track   | `docs/user-guide/`  |

Both tracks are **multi-file** — generate the full set, do not produce a single README. See Step 2a/2b for required file lists.

#### Project-dependent docs (generate only when requested / needed)

| Input              | Doc Type                             | Output Location                              |
| ------------------ | ------------------------------------ | -------------------------------------------- |
| `readme`           | Project README                       | Project root `README.md`                     |
| `plan <name>`      | Work / implementation plan (folder)  | `docs/plans/YYYYMMDD-{plan-name}/` (see 2c)  |
| `adr <decision>`   | Standalone ADR                       | `docs/architecture/adr/ADR-NNNN-{title}.md`  |
| `design <feature>` | Feature design document              | `docs/architecture/design/{feature-name}.md` |
| `overview`         | Architecture overview                | `docs/architecture/overview.md`              |
| `api <module>`     | API / module documentation           | `docs/api/{module}-api.md`                   |
| `ipc`              | IPC channel reference (Electron)     | `docs/api/ipc-channels.md`                   |
| `entities`         | Database entity reference (Electron) | `docs/api/entities.md`                       |
| `providers`        | Provider pattern reference (Library) | `docs/api/providers.md`                      |
| `guide <topic>`    | How-to / tutorial                    | `docs/guides/{topic}-guide.md`               |
| `reference <topic>`| Internal reference material          | `docs/reference/{topic}.md`                  |
| `fix <issue>`      | Bug fix record                       | `docs/fix/{issue-name}.md`                   |
| `changelog`        | Version changelog                    | `docs/changelog/CHANGELOG.md`                |
| `<file-path>`      | JSDoc for public APIs in file        | Inline in source file                        |

### Step 2a: `onboarding` track structure (required)

Target audience: **new developers joining the project**. Write sequentially — each file builds on the previous one.

```
docs/onboarding/
├── README.md                    # Index + reading order
├── 00-start-here.md             # Entry point, prerequisites, map
├── 01-project-overview.md       # What the product does, who uses it
├── 02-system-architecture.md    # High-level architecture (processes, layers)
├── 03-project-structure.md      # Folder walkthrough
├── 04-core-modules.md           # Key modules and responsibilities
├── 05-main-workflows.md         # Critical runtime flows end-to-end
├── 06-development-workflow.md   # Install, run, build, test, debug
├── 07-how-to-add-feature.md     # Recipe for adding a new feature
├── 08-how-to-modify-safely.md   # Impact analysis + safe-change rules
├── 09-debugging-guide.md        # Common bugs, tools, logs
└── 10-common-pitfalls.md        # Traps to avoid
```

Rules:
- File names are **numbered `NN-kebab-case.md`** so reading order is explicit.
- Every file links forward/backward (prev / next).
- `README.md` is an index only — not narrative content.

### Step 2b: `user-guide` track structure (required)

Target audience: **end users of the product** (not developers). No code internals.

```
docs/user-guide/
├── README.md                 # Index + what this guide covers
├── 01-introduction.md        # What the product is and who it's for
├── 02-getting-started.md     # Install, first launch, first success
├── 03-<core-concept>.md      # Core domain concept (e.g. architecture from user view)
├── 04-configuration.md       # Settings and options
├── 05-<feature-area-1>.md    # Main feature area
├── 06-<feature-area-2>.md    # ...
├── ...                       # One file per feature area
├── NN-error-handling.md      # How the product reports and recovers from errors
└── NN-development-guide.md   # Optional: for power users / plugin authors
```

Rules:
- File names are **numbered `NN-kebab-case.md`**.
- Feature area file count adapts to the project — not a fixed number.
- Screenshots / diagrams go next to the file that references them.
- No source code paths or internal class names in user-facing copy.

### Step 2c: `plan <name>` folder structure (when generating a plan)

A plan is **never a single file**. Always generate the full folder:

```
docs/plans/YYYYMMDD-{plan-name}/
├── overview.md                  # Executive summary, goals, scope, links to sub-docs
├── business-tdd/
│   ├── business.md              # Business requirements / user value / acceptance
│   └── tdd.md                   # Test-driven design: test cases before code
├── design/
│   ├── architecture.md          # Target architecture / module layout
│   ├── execution-plan.md        # Phased work breakdown (Phase 1..N, tasks, owners)
│   ├── impact-analysis.md       # Blast radius, affected files, risks surface
│   └── risks.md                 # Risks, mitigations, rollback strategy
└── adr/
    ├── ADR-001-{decision}.md    # One ADR per non-obvious decision in the plan
    ├── ADR-002-{decision}.md
    └── ...
```

Rules:
- Folder name: `YYYYMMDD-{kebab-case-plan-name}` — date is the plan creation date.
- `overview.md` is mandatory and links to every sub-document.
- `business-tdd/` and `design/` are mandatory.
- `adr/` is mandatory but may start with a single ADR; add more as decisions emerge.
- Do **not** create `docs/plans/YYYYMMDD-{name}.md` (flat file) — always a folder.
- ADRs inside a plan are scoped to that plan; project-wide ADRs still live in `docs/architecture/adr/`.

### Step 3: Detect Project Type

> Project type detection: see `.claude/rules/project-detection.md`

Regardless of project type, the following tracks are **always required** and must exist (create if missing):

- `docs/onboarding/` — full numbered track per Step 2a
- `docs/user-guide/` — full numbered track per Step 2b

After detection, apply project-specific extra doc types on top:

- **Electron**: `ipc`, `entities`, `guide`, `fix`
- **Library**: `providers`, `api`
- **Any**: `plan`, `adr`, `design`, `overview`, `changelog` as needed

If the user runs `/generate-docs` without arguments, check whether `docs/onboarding/` and `docs/user-guide/` exist — if either is missing, surface it as a gap in Step 5 and offer to bootstrap.

### Step 4: Delegate to Agent

Delegate to the **doc-writer** agent with full context from Steps 1-3.
The agent follows its complete process defined in `.claude/agents/doc-writer.md`:

1. Analyze project (structure, metadata, existing docs)
2. Generate documentation using skill templates
3. Write to correct location per doc type

### Step 5: Report

For single-file outputs:

```markdown
## Documentation Generated

### Files Created/Updated

| File                          | Type  | Status  |
| ----------------------------- | ----- | ------- |
| `docs/guides/{name}-guide.md` | Guide | Created |

### Required-tracks check

- `docs/onboarding/` — present / **missing — bootstrap recommended**
- `docs/user-guide/` — present / **missing — bootstrap recommended**

### Remaining Gaps

- <what documentation is still needed>

### Suggested Follow-ups

- <related docs that should be created>
```

For multi-file tracks (`onboarding`, `user-guide`, `plan`):

```markdown
## Documentation Generated

### {Track name} ({N} files)

| File                                | Status  |
| ----------------------------------- | ------- |
| `docs/onboarding/README.md`         | Created |
| `docs/onboarding/00-start-here.md`  | Created |
| `docs/onboarding/01-project-overview.md` | Created |
| ...                                 | ...     |

### Required-tracks check

- `docs/onboarding/` — **just generated** ✓
- `docs/user-guide/` — present / **still missing**

### Remaining Gaps

- <e.g. user-guide track still missing>

### Suggested Follow-ups

- `/generate-docs user-guide` to bootstrap the other required track
```

#### Bootstrap-on-empty flow

If `/generate-docs` is invoked **without arguments**:

1. Check whether `docs/onboarding/` and `docs/user-guide/` exist.
2. For each missing track, ASK the user (do not auto-create) whether to bootstrap it now.
3. If user confirms, generate the full track per Step 2a / 2b.
4. If user declines, list the gap in the report so it stays visible.

## Notes

- Always check existing docs before generating — update, don't duplicate
- **Per-file** size limit ~3 pages. Multi-file tracks (`onboarding/`, `user-guide/`, plan folders) are large by design — the limit is on each file, not the total.
- Focus on "why" and "how", not "what"
- Include working code examples that compile
- No secrets or credentials in documentation
- Plans are **folders**, never flat files. If you find an old `docs/plans/YYYYMMDD-{name}.md`, treat it as legacy and convert to folder structure when next touched.
- Fix records live in `docs/fix/{issue-name}.md`, not `docs/troubleshooting/`.
