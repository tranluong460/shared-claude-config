---
description: Unified test command — generate unit tests OR perform production readiness analysis. Routes via $ARGUMENTS subcommand.
category: test
mutates: false
consumes: [source-code, system-description]
produces: [test-files, production-readiness-report]
result_states: [success, validation_failed, blocked, safe, conditional, unsafe, execution_error]
next_on_result:
  success: [implement]
  conditional: [implement, plan]
  unsafe: [audit, implement, plan]
  validation_failed: [audit]
  execution_error: [audit]
---

You are executing the `/test` command. Consolidates `/generate-tests` and `/test-system` under one entry point.

## Input

```
/test <subcommand> [target...]
```

| Subcommand | Behavior | Delegates to | Mutates |
|---|---|---|---|
| `generate [target]` | Generate unit/integration tests; bootstrap infra if needed (default) | test-architect | **yes** |
| `setup` | Bootstrap test framework only (vitest), then stop | test-architect | **yes** |
| `system <target>` | Production readiness analysis — multi-agent risk assessment | test-leader | no |

If `$ARGUMENTS` is empty or starts with a path/file, default to `generate`.

> Test rules auto-inject via `.claude/rules/testing.md`. Mock patterns and testability guides live in `skills/testing-strategy/SKILL.md`. Production testing methodology lives in `skills/production-testing/SKILL.md`.

## Workflow

### Step 1: Parse subcommand

Parse the first token of `$ARGUMENTS`:
- Recognized: `generate`, `setup`, `system`
- Anything else → treat as `generate <args>`
- Strip subcommand from args; remainder is target.

### Step 2: Route

---

## Playbook: `generate` — Unit/integration test generation

**Skills**: `testing-strategy`, `coding-standards`, `naming-conventions`, `testing-methodology`, `project-context`
**Rules auto-injected**: `testing.md`, `testing-methodology.md`
**Agent**: `test-architect` (or merged `test-manager` mode `design` after Phase 4)

1. **Detect test infrastructure**:
   - `package.json` → vitest/jest in deps?
   - Glob: `vitest.config.*`, `jest.config.*`, `**/*.test.ts`, `test/**/*.ts`

   | Scenario | Action |
   |---|---|
   | Framework exists | Use it, match existing patterns |
   | No framework | Bootstrap vitest (see skill) |
   | Subcommand `setup` | Bootstrap only, stop |

2. **Delegate to test-architect agent**. The agent runs:
   - Analyze target (public API, dependencies, edge cases)
   - Create test plan with mock strategy
   - Generate tests following AAA pattern
   - Run and verify

3. **Output**:
   ```markdown
   ## Tests Generated: <target>

   | File | Tests | Passing |
   |---|---|---|
   | `<test-file>` | N | N |

   ### Suggested Next Tests
   - <what to test next>
   ```

---

## Playbook: `system` — Production readiness analysis

**Skills**: `production-testing`, `coding-standards`, `architecture-patterns`, `testing-strategy`, `project-context`
**Agent**: `test-leader` (or merged `test-manager` mode `production` after Phase 4)

This command performs **analytical risk assessment** — it does NOT run automated tests.

1. **Validate input**: If system details are unclear, STOP and ask for clarification. Do NOT assume.
2. **System understanding** (mandatory before testing):
   - What does this system do?
   - Who are the real users?
   - What are the critical user actions?
   - What would failure cause? (data loss, downtime, revenue loss)
   - System boundaries (inside vs outside)?
3. **Risk assessment & dynamic team creation**:
   - Identify risk areas
   - Impact × Likelihood matrix
   - Create only the tester roles needed for this system
   - Assign focus areas and key scenarios
4. **Execute testing**: spawn subagent per role, each tester explores deeply (edge cases, failure chains, cascade analysis), provides findings with concrete evidence.
5. **Interrogate every finding**:
   - Real issue? (concrete scenario required)
   - Can happen in production? (reality check)
   - Impact? (users affected, business damage)
   - Cascade? (isolated vs system-wide)
   - REJECT vague, assumption-based, or unrealistic findings.
6. **Output**: Production Testing Report with System Understanding, Team Composition, Risk Areas, Critical Findings (with Evidence/Impact/Cascade/Recommendation), What Matters vs Doesn't, Unknown Risks, **Final Judgment** (SAFE / CONDITIONAL / UNSAFE), Confidence, Top risks, Next steps.

**Notes**:
- Depth over breadth: 5 deep findings beat 50 shallow ones.
- Every finding needs concrete evidence (code reference, scenario, chain of events).
- Test leader makes the final call — no neutral or vague conclusions.
- For systems with external dependencies: focus on how THIS system handles failure, not testing the external service.
- After testing: `/implement` for critical fixes, `/plan` for structural improvements.
