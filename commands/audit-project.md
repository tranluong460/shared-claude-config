---
description: Full architecture audit of the project — structure, dependencies, patterns, and health assessment
category: audit
mutates: false
consumes: [source-code, package-json]
produces: [architecture-report]
next_on_success: [audit-code, audit-naming, refactor-plan]
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
- `.claude/skills/project-context/SKILL.md` (if filled in)

### Step 2: Detect Project Type

> Project type detection: see `.claude/rules/project-detection.md`

After detection, apply project-specific checklists:
- **Electron**: Electron + General
- **Library**: Provider Pattern + General
- **Server**: Server + General

### Step 3: Project Metadata

Read and analyze:

```
package.json          -> name, version, scripts, dependencies, devDependencies
tsconfig.json         -> compiler options, path aliases
.gitmodules           -> submodule definitions (if exists)
```

Extract: Technology Stack, Scripts inventory, Dependency count, Path aliases.

### Step 4: Delegate to Agent

Delegate to the **architect** agent with full context from Steps 1-3.
The agent follows its complete audit process defined in `.claude/agents/architect.md`:

1. Structure scan (file counts, god modules, orphan files, barrel exports)
2. Dependency direction analysis (circular deps, import violations)
3. Type safety scan (any, empty catch, console.log, hardcoded secrets)
4. Project-type-specific audit (IPC sync, provider pattern, process isolation)
5. General checklist evaluation

### Step 5: Report

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
| Key frameworks | <ORM, UI, state, etc.>                         |

### Technology Stack

| Layer            | Technology                   |
| ---------------- | ---------------------------- |
| Runtime          | Node.js / Electron           |
| Database         | <TypeORM + SQLite / none>    |
| Build            | <electron-vite / Vite / tsc> |

### Architecture Summary

- Pattern: <Electron multi-process / Provider-based library>
- Module count: N
- Total source files: N

### IPC Channel Inventory (Electron only)

| Domain | Handler (main/) | Proxy (preload/) | Status |
| --- | --- | --- | --- |
| account | ✅ | ✅ | Synced |

### Provider Inventory (Library only)

| Provider | Factory | Provider Class | Actions | Status |
| --- | --- | --- | --- | --- |
| automated | ✅ | ✅ | N | OK |

### Strengths

1. <strength with evidence>

### Critical Issues

1. **<issue>** [file:line]
   - Impact: <what breaks>
   - Recommendation: <specific fix>

### Major Issues

1. **<issue>** [file:line]

### Improvement Roadmap

| Priority | Issue | Category | Effort | Impact |
| --- | --- | --- | --- | --- |
| 1 | <issue> | Security/Structure/Quality | S/M/L | High/Med/Low |

### Dependency Summary

| Metric | Count |
| --- | --- |
| Production deps | N |
| Dev deps | N |
```

## Notes

- Auto-detect project type before applying checklist
- Evidence-based: every finding must reference a specific file or pattern
- Actionable: every issue must have a specific fix recommendation
- For deep naming audit, recommend `/audit-naming` separately
- For deep code review, recommend `/audit-code` on specific modules
- If 100+ files, focus on critical modules first and note unaudited areas
