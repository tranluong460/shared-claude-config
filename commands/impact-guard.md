---
description: Analyze blast radius of code changes, map dependencies, and protect business logic from unintended side effects
category: analyze
mutates: false
consumes: [source-code, git-history]
produces: [impact-report]
result_states: [safe_to_proceed, proceed_with_caution, blocked, execution_error]
next_on_result:
  safe_to_proceed: [implement, refactor-plan]
  proceed_with_caution: [generate-tests, implement]
  blocked: [generate-tests]
  execution_error: [diagnose]
---

You are executing the `/impact-guard` command.

## Input

$ARGUMENTS — target of analysis. Can be:

- **File path**: `/impact-guard src/services/payment.service.ts` — analyze impact of changing this file
- **Function name**: `/impact-guard calculateDiscount` — analyze impact of changing this function
- **Git diff**: `/impact-guard --diff` — analyze impact of current unstaged/staged changes
- **Description**: `/impact-guard "thay đổi cách tính giá sản phẩm"` — describe what you plan to change

### Examples

```
/impact-guard src/main/ipc/account.ts
/impact-guard processPayment
/impact-guard --diff
/impact-guard "rename column user.name to user.full_name"
/impact-guard src/utils/validation.ts:validateEmail
```

## Workflow

### Step 1: Load Skills

Read and apply:

- `.claude/skills/impact-analysis/SKILL.md`
- `.claude/skills/coding-standards/SKILL.md`
- `.claude/skills/architecture-patterns/SKILL.md`

### Step 2: Detect Project Type

> Project type detection: see `.claude/rules/project-detection.md`

After detection, apply project-specific risk factors:

- **Electron**: IPC boundary sync, cross-process impact, preload consistency
- **Library**: Public API surface, consumer impact, semver implications
- **Server**: API contract stability, middleware chain, DB migration safety

### Step 3: Determine Analysis Target

Based on $ARGUMENTS, determine what code is being analyzed:

**If file path**: Read the file, identify all exported functions/classes/types
**If function name**: Grep across project to locate the function, then read its file
**If --diff**: Run `git diff` and `git diff --cached` to get current changes, identify all modified functions
**If description**: Parse the intent, locate relevant files/functions via Grep

### Step 4: Delegate to Agent

Delegate to the **impact-analyst** agent with full context from Steps 1-3.

The agent follows its complete analysis process defined in `.claude/agents/impact-analyst.md`:

1. **Identify Change Scope** — what exactly is changing, exported vs internal
2. **Map Dependency Graph** — Level 1 (direct), Level 2 (transitive), Level 3 (cross-boundary)
3. **Classify Business Logic** — assign Business Tier (1-4) to affected code
4. **Map Test Coverage** — find tests covering affected code, identify gaps
5. **Git History Analysis** — co-change patterns, recent modifications, warnings in code
6. **Risk Assessment** — produce overall risk level and recommended strategy

### Step 5: Generate Impact Report

Present a structured report:

```markdown
## 🛡️ Impact Guard Report

### Target
- **Change**: <what is being changed>
- **File(s)**: <affected file paths>
- **Scope**: Internal / Exported / Public API

### Business Logic Tier: <1/2/3/4>
<Reasoning for tier assignment>

### Blast Radius

#### Level 1 — Direct Dependencies (<N> files)
| File | Function | Dependency Type | Risk |
| --- | --- | --- | --- |
| path:line | name() | calls/extends/imports | Low/Med/High |

#### Level 2 — Transitive Dependencies (<N> files)
| File | Function | Through | Risk |
| --- | --- | --- | --- |

#### Cross-Boundary Impact
| Boundary | Affected? | Details |
| --- | --- | --- |
| Database | Yes/No | <tables/columns> |
| API Contract | Yes/No | <endpoints> |
| Process Boundary | Yes/No | <main/preload/renderer> |
| External Consumers | Yes/No | <packages/projects> |

### Test Coverage
- **Total affected functions**: N
- **Functions with tests**: X/N (Y%)
- **Coverage gaps**: <list uncovered functions>
- **Missing scenarios**: <edge cases not tested>

### Git Co-Change Pattern
- **Frequently co-changed files**: <list>
- **Recent authors**: <who has been working on this>
- **Code warnings found**: <DO NOT MODIFY, etc.>

### Risk Assessment

| Factor | Level | Details |
| --- | --- | --- |
| Blast radius | Low/Med/High | N files, M functions affected |
| Test coverage | Low/Med/High | Y% coverage |
| Business criticality | Tier 1-4 | <reasoning> |
| Rollback complexity | Low/Med/High | <reasoning> |
| Co-change risk | Low/Med/High | <hidden dependencies> |
| **Overall Risk** | **<level>** | |

### Verdict: <SAFE ✅ / CAUTION ⚠️ / BLOCKED 🛑>

### Recommended Strategy
- **Approach**: <Direct / Expand-Contract / Feature Flag / Parallel Run>
- **Why**: <reasoning>

### Action Items (Before Making Changes)
1. [ ] <write tests for X>
2. [ ] <create migration for Y>
3. [ ] <update callers A, B, C incrementally>
4. [ ] <verify with: command>

### Safe Change Plan
<Step-by-step instructions for making the change safely>

### Verification Checklist
- [ ] All existing tests pass
- [ ] New tests cover changed behavior
- [ ] No TypeScript errors: `npm run typecheck`
- [ ] Lint passes: `npm run flint`
- [ ] <project-specific checks>
```

### Step 6: Determine Result State

Based on the analysis:

- **safe_to_proceed**: Overall Risk is Low, adequate test coverage, small blast radius
- **proceed_with_caution**: Overall Risk is Medium, some gaps but manageable
- **blocked**: Overall Risk is High/Critical, must address pre-conditions first
- **execution_error**: Could not complete analysis (missing files, parse errors)

Present the verdict clearly and wait for user decision before any next steps.

## Notes

- This command is **read-only** — it never modifies code
- Always present concrete file:line references, not vague descriptions
- When in doubt, classify risk as higher rather than lower
- Include Vietnamese explanations alongside technical terms for clarity
- If test coverage is 0% for a Tier 1-2 function, always result in `blocked`
- Co-change analysis may reveal dependencies not visible through static imports
- For `--diff` mode, analyze ALL changes in the diff, not just the first file
- The goal is to PROTECT business logic — err on the side of caution
