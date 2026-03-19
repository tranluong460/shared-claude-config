---
description: Full architecture audit of the project — structure, dependencies, patterns, and health assessment
---

You are executing the `/audit-project` command.

## Input

Target: $ARGUMENTS (specific module, or entire project if not specified)

## Workflow

### Step 1: Load Skills

Read and apply:

- `.claude/skills/architecture-patterns/SKILL.md`
- `.claude/skills/coding-standards/SKILL.md`
- `.claude/skills/naming-conventions/SKILL.md`

### Step 2: Detect Project Type

> Project type detection: see `.claude/rules/project-detection.md`

After detection, apply project-specific checklists:
- **Electron**: Electron + General
- **Library**: Provider Pattern + General
- **Server**: Server + General
- **None of above**: General only

### Step 3: Project Metadata

Read and analyze:

```
# Core files to read
package.json          → name, version, scripts, dependencies, devDependencies
tsconfig.json         → compiler options, path aliases, composite projects
.gitmodules           → submodule definitions (if exists)
```

Extract:

- **Technology Stack**: ORM, UI framework, state management, build tools, test framework
- **Scripts inventory**: Available npm scripts (dev, build, test, lint, etc.)
- **Dependency count**: production vs dev vs peer
- **Path aliases**: @main/, @renderer/, @preload/, etc.

### Step 4: Architecture Analysis

#### 4a. Structure Scan

Scan the full project structure:

```
# All source files (exclude node_modules, dist, out, .git)
src/**/*.ts
src/**/*.tsx

# Count files per directory to find hot spots
```

Identify:

- Total file count per directory
- God modules (files > 300 lines)
- Orphan files (no imports from other modules)
- Missing barrel exports (`index.ts`)

#### 4b. Dependency Direction

Trace import patterns across module boundaries:

- Main process should not import from renderer
- Renderer should not import from main (only through preload)
- Inner layers should not import from outer layers
- Check for circular dependencies (A → B → A)

#### 4c. Type Safety Scan

Search for code quality indicators:

```
# any type usage
pattern: ": any" or "as any"

# Empty catch blocks
pattern: "catch" followed by empty block

# console.log in production code
pattern: "console.log" (outside test files)

# Hardcoded secrets
pattern: password, secret, api_key, token (with string values)
```

### Step 5: Project-Type-Specific Audit

---

#### Electron App Audit

##### 5e-1. Process Isolation

> Enforcement: `.claude/rules/electron.md`

| Check                          | How to verify                                                       |
| ------------------------------ | ------------------------------------------------------------------- |
| Context isolation enabled      | Search for `contextIsolation` in window creation                    |
| No `nodeIntegration: true`     | Search for `nodeIntegration` — must be false or absent              |
| No `require()` in renderer     | Grep renderer/ for `require(` — should find none                    |
| No Node.js imports in renderer | Grep renderer/ for `import.*from 'fs'`, `'path'`, `'child_process'` |

##### 5e-2. IPC Handler ↔ Preload Consistency

**Critical check** — The IPC contract must be consistent across all three processes:

1. List all IPC handler files in `src/main/ipc/`
2. List all IPC proxy files in `src/preload/ipc/`
3. Verify 1:1 mapping — every main handler has a matching preload proxy
4. Check that IPC channels follow `{domain}_{action}` naming convention
5. Verify typed IPC usage (`@electron-toolkit/typed-ipc` or custom typing)

##### 5e-3. Data Flow Pipeline

Trace the full data path for at least 2 domains (e.g., account, setting):

```
React Component (pages/)
  ↓ calls hook
React Query Hook (hooks/useReadXxx.ts)
  ↓ calls API
API Endpoint (services/api/endpoints/xxx.ts)
  ↓ calls window.api
Preload Proxy (preload/ipc/xxx.ts)
  ↓ ipcRenderer.invoke
Main IPC Handler (main/ipc/xxx.ts)
  ↓ database query or service call
Database / Service Layer
```

Verify:

- [ ] Each step exists and is correctly wired
- [ ] No step is bypassed (e.g., component calling IPC directly)
- [ ] Error handling exists at each boundary
- [ ] React Query keys are unique per query

##### 5e-4. Window Management

- [ ] Window types registered centrally (not scattered)
- [ ] Splash screen flow: splash → auth check → main window
- [ ] Single instance lock implemented (`requestSingleInstanceLock`)
- [ ] Graceful shutdown: `before-quit` handles cleanup

##### 5e-5. Worker Thread Architecture

- [ ] Heavy operations (browser automation, file processing) in worker threads
- [ ] Worker communication uses MessagePort/MessageChannel
- [ ] Worker errors handled (no silent failures)
- [ ] Job queue manages concurrency (thread limits)

##### 5e-6. Database Health

- [ ] TypeORM entities are well-defined (proper columns, relations)
- [ ] WAL mode enabled for SQLite (concurrent read/write)
- [ ] Migrations or synchronize strategy documented
- [ ] QueryBuilder usage is type-safe (no raw SQL unless necessary)
- [ ] Subscribers/listeners are registered

##### 5e-7. Git Submodule Health

- [ ] `.gitmodules` defines correct branches for each submodule
- [ ] Submodule references are up-to-date (not stale commits)
- [ ] Main process and renderer use correct branches
- [ ] Submodule update script exists (`npm run submodule` or similar)

##### 5e-8. Build Pipeline

- [ ] `electron.vite.config.ts` properly configured for main/preload/renderer
- [ ] `electron-builder.yml` has correct targets (win/mac/linux)
- [ ] Auto-version script works correctly
- [ ] Build scripts run in correct order (pre → build → post)
- [ ] External dependencies properly excluded from bundle

---

#### Module-Based Library Audit

##### 5m-1. Provider Pattern Compliance

> Provider structure: see `.claude/rules/provider-pattern.md`

For each provider in `src/providers/`, verify compliance with the canonical pattern.

##### 5m-2. Core Framework Health

- [ ] `PluginLoader` correctly resolves provider paths
- [ ] `ProviderRegistry` is static singleton (no duplicate registration)
- [ ] `ProviderFacade` is the single entry point for consumers
- [ ] Generic typing on `getProvider<T>()` returns correct provider type

##### 5m-3. Interface Contract Stability

- [ ] `ILabsProviderFactory` interface is minimal and stable
- [ ] Provider interfaces (`IScriptedProvider`, `IAutomatedProvider`, `IDirectApiProvider`) share common shape
- [ ] `IPayloadProvider<T>` is properly generic-typed per provider
- [ ] `ProviderTypeMap` maps all enum values

##### 5m-4. Library Packaging

- [ ] Public API exported through single `index.ts`
- [ ] Internal utilities in `utils/private/` not re-exported
- [ ] Dual format build (ESM + CJS)
- [ ] TypeScript declarations generated (`.d.ts`)
- [ ] External dependencies correctly marked in `rollupOptions.external`
- [ ] `package.json` has correct `main`, `module`, `types` fields

---

### Step 6: General Audit Checklist

> The architect agent (`.claude/agents/architect.md`) applies the full audit checklist automatically. See the agent for details.

### Step 7: Report

Generate a comprehensive audit report:

```markdown
## Project Audit: <project name>

### Health Score: X/10

### Project Profile

| Field          | Value                                          |
| -------------- | ---------------------------------------------- |
| Name           | <package name>                                 |
| Version        | <version>                                      |
| Type           | Electron App / Module Library / Node.js Server |
| Node target    | <from tsconfig>                                |
| Key frameworks | <ORM, UI, state, etc.>                         |
| Build tool     | <electron-vite / vite / tsc>                   |
| Test framework | <vitest / jest / none>                         |

### Technology Stack

| Layer            | Technology                   |
| ---------------- | ---------------------------- |
| Runtime          | Node.js / Electron           |
| Language         | TypeScript                   |
| Database         | <TypeORM + SQLite / none>    |
| UI Framework     | <Mantine + Tailwind / none>  |
| State Management | <React Query / Redux / none> |
| HTTP Client      | <Axios + HttpClient / fetch> |
| Build            | <electron-vite / Vite / tsc> |
| Package Manager  | <yarn / npm / pnpm>          |

### Architecture Summary

- Pattern: <Electron multi-process / Provider-based library / Feature-based>
- Module count: N
- Total source files: N
- Avg file size: N lines

### Data Flow Diagram (Electron only)
```

Page → Hook → API → Preload → IPC Handler → DB/Service

```

### Module Map

<tree structure of key modules with descriptions>

### IPC Channel Inventory (Electron only)

| Domain | Handler (main/) | Proxy (preload/) | Status |
| --- | --- | --- | --- |
| account | ✅ | ✅ | Synced |
| auth | ✅ | ✅ | Synced |
| ... | ... | ... | ... |

### Provider Inventory (Library only)

| Provider | Factory | Provider Class | Actions | Status |
| --- | --- | --- | --- | --- |
| automated | ✅ | ✅ | N | OK |
| scripted | ✅ | ✅ | N | OK |
| ... | ... | ... | ... | ... |

### Strengths

1. <strength with evidence>
2. <strength with evidence>

### Critical Issues

1. **<issue>** [file:line]
   - Impact: <what breaks>
   - Recommendation: <specific fix>

### Major Issues

1. **<issue>** [file:line]
   - Impact: <what degrades>
   - Recommendation: <specific fix>

### Minor Issues

1. **<issue>** [file:line]
   - Recommendation: <fix>

### Improvement Roadmap

| Priority | Issue | Category | Effort | Impact |
| --- | --- | --- | --- | --- |
| 1 | <issue> | Security/Structure/Quality | S/M/L | High/Med/Low |
| 2 | <issue> | ... | ... | ... |

### Dependency Summary

| Metric | Count |
| --- | --- |
| Production deps | N |
| Dev deps | N |
| Potentially unused | N |
| Security vulnerabilities | N |
| Outdated (major) | N |

### Submodule Status (if applicable)

| Submodule | Branch | Status |
| --- | --- | --- |
| src/main/mkt-core | main | Up-to-date / Stale |
| src/renderer/src/mkt-core | renderer-v2 | Up-to-date / Stale |

### Build Pipeline Status

| Step | Script | Status |
| --- | --- | --- |
| Pre-build | beforbuild | ✅/❌ |
| Type check | typecheck | ✅/❌ |
| Build | build-core | ✅/❌ |
| Post-build | afterbuild | ✅/❌ |
```

## Notes

- Auto-detect project type before applying checklist — don't apply Electron checks to a library
- Evidence-based: every finding must reference a specific file or pattern
- Actionable: every issue must have a specific fix recommendation
- Balanced: acknowledge strengths, not just problems
- Prioritized: Critical → Major → Minor → Nice-to-have
- For deep naming audit, recommend running `/audit-naming` separately
- For deep code review, recommend running `/review` on specific modules
- If the project is large (100+ files), focus on the most critical modules first and note which areas were not fully audited
