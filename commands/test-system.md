---
description: Production readiness testing — multi-agent team analyzes system risks, failure scenarios, and makes ship/no-ship judgment
category: verify
mutates: false
consumes: [source-code, system-description]
produces: [production-readiness-report]
result_states: [safe, conditional, unsafe, execution_error]
next_on_result:
  safe: []
  conditional: [implement, refactor-plan]
  unsafe: [diagnose, implement, refactor-plan]
  execution_error: [diagnose]
---

You are executing the `/test-system` command.

## Input

Target: $ARGUMENTS (system description, module path, or feature area to test)

## Workflow

### Step 1: Load Skills

Read and apply:

- `.claude/skills/production-testing/SKILL.md`
- `.claude/skills/coding-standards/SKILL.md`
- `.claude/skills/architecture-patterns/SKILL.md`
- `.claude/skills/testing-strategy/SKILL.md`
- `.claude/skills/project-context/SKILL.md` (if filled in)

### Step 2: Delegate to Agent

Delegate to the **test-leader** agent with full context from the input and environment.

### Step 3: Validate Input

If system details are unclear or missing:
- STOP and ask the user for clarification
- DO NOT proceed with assumptions

If input is a module path:
- Read the code to build system understanding
- Map data flows, state management, external dependencies

If input is a description:
- Parse and identify the system scope
- Ask for code paths if needed

### Step 4: System Understanding

The test leader MUST complete this phase before any testing:

1. What does this system do?
2. Who are the real users?
3. What are the critical user actions?
4. What would failure cause? (data loss, downtime, revenue loss)
5. What are the system boundaries? (inside vs outside)

### Step 5: Risk Assessment & Team Creation

1. Identify all risk areas based on system understanding
2. Assess risks using Impact x Likelihood matrix
3. Create dynamic tester roles (only roles needed for this system)
4. Assign focus areas and key scenarios to each role

### Step 6: Execute Testing

For each tester role:

1. Spawn subagent with specific focus area and risk context
2. Each tester explores their domain deeply (edge cases, failure chains, cascade analysis)
3. Each tester provides findings with concrete evidence

### Step 7: Interrogate & Validate

The test leader interrogates every finding:

1. Is this a real issue? (concrete scenario required)
2. Can this happen in production? (reality check)
3. What is the impact? (users affected, business damage)
4. Can it cascade? (isolated vs system-wide)

REJECT findings that are vague, assumption-based, or unrealistic.

### Step 8: Report

```markdown
## Production Testing Report: <system>

### System Understanding

- Purpose: <what it does>
- Users: <who uses it>
- Critical actions: <what matters most>
- Boundaries: <inside vs outside>

### Team Composition

| Role | Focus | Findings |
| --- | --- | --- |
| <role> | <area> | N critical, N high, N medium |

### Risk Areas

| Area | Risk Level | Coverage |
| --- | --- | --- |
| <area> | Critical/High/Medium | Tested/Partial/Not tested |

### Critical Findings

1. **[severity]** <finding>
   - **Evidence**: <code reference, scenario, chain of events>
   - **Impact**: <who/what affected, business damage>
   - **Cascade risk**: Isolated / Can cascade
   - **Recommendation**: <specific fix>

### What Matters vs What Does Not

| Matters (test deeply) | Does Not Matter (skip) |
| --- | --- |
| <item> | <item> |

### Unknown Risks

- <area or assumption not verified>

### Final Judgment

- **Verdict**: SAFE / CONDITIONAL / UNSAFE
- **Confidence**: High / Medium / Low
- **Top risks**:
  1. <most critical risk>
  2. <second risk>
  3. <third risk>
- **Recommendation**: <specific next steps>
```

## Notes

- This command does NOT run automated tests — it performs analytical risk assessment
- Depth over breadth: 5 deep findings beat 50 shallow ones
- Every finding must have concrete evidence (code reference, scenario, chain of events)
- The test leader makes the final call — no neutral or vague conclusions
- For systems with external dependencies: focus on how THIS system handles failure, not on testing external services
- After testing, use `/implement` to fix critical issues or `/refactor-plan` for structural improvements
