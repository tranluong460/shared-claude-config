---
name: production-testing
description: Multi-agent production testing methodology — system understanding, risk assessment, failure imagination, proof-based validation, and production readiness judgment.
layer: testing
---

# Production Testing Methodology — Reference

> This skill provides the knowledge framework for production-readiness testing. The `test-manager` agent (mode: production) uses this to direct multi-agent testing teams.

## Core Philosophy

You are NOT testing features. You are **protecting a production system from failure**.
Think like a paranoid SRE. Challenge everything. Trust only what can be clearly proven.

## Phase 1: System Understanding (MANDATORY)

Before creating any tests, you MUST:

1. **What does this system do?** — Core purpose and business value
2. **Who are the real users?** — User personas and usage patterns
3. **Critical user actions** — What actions generate revenue, store data, or affect other users
4. **Failure impact** — What failure would cause real damage (data loss, downtime, revenue loss)
5. **System behavior map** — Flow, logic, data paths, state transitions

### System Boundary Awareness

Clearly define:

| Boundary                     | Examples                                              |
| ---------------------------- | ----------------------------------------------------- |
| **Inside** (controllable)    | Application code, database, local state, IPC handlers |
| **Outside** (uncontrollable) | External APIs, network, OS, hardware, user behavior   |

Focus on how the system behaves when dependencies fail, not on testing external systems.

## Phase 2: Risk Identification

### Risk Categories

| Category            | Description                                    | Examples                                            |
| ------------------- | ---------------------------------------------- | --------------------------------------------------- |
| **Data integrity**  | Data loss, corruption, inconsistency           | Failed writes, partial updates, race conditions     |
| **Availability**    | System downtime, degraded service              | Crash loops, memory leaks, deadlocks                |
| **Security**        | Unauthorized access, data exposure             | Injection, privilege escalation, token leaks        |
| **Business logic**  | Incorrect behavior that produces wrong results | Calculation errors, state machine violations        |
| **User experience** | Functional but unusable                        | Infinite loading, silent failures, confusing errors |

### Risk Assessment Matrix

| Impact       | Likelihood: Rare | Likelihood: Occasional | Likelihood: Frequent |
| ------------ | ---------------- | ---------------------- | -------------------- |
| **Critical** | Medium           | High                   | Critical             |
| **Major**    | Low              | Medium                 | High                 |
| **Minor**    | Info             | Low                    | Medium               |

## Phase 3: Dynamic Team Creation

Create tester roles based on the system's actual risks. Do NOT create unnecessary roles.

### Role Template

```markdown
| Role   | Focus Area      | Risk Addressed | Key Scenarios       |
| ------ | --------------- | -------------- | ------------------- |
| <name> | <specific area> | <which risk>   | <3-5 key scenarios> |
```

### Common Role Patterns

| System Type         | Typical Roles                                                              |
| ------------------- | -------------------------------------------------------------------------- |
| **Electron app**    | IPC tester, DB integrity tester, process isolation tester, UI state tester |
| **API server**      | Auth tester, data flow tester, concurrency tester, error handling tester   |
| **Library**         | Contract tester, edge case tester, integration tester                      |
| **Pipeline/worker** | Ordering tester, retry/recovery tester, resource leak tester               |

### Role Boundaries

- Leader defines: WHAT areas, WHAT risks, WHAT to ignore
- Testers own: HOW to break their area, edge cases, failure scenarios
- Testers are NOT simple executors — they are specialists who think deeply

## Phase 4: Execution Mindset

### Tester Thinking Model

Think like real users:

- Unpredictable behavior (click fast, navigate away mid-action, retry on failure)
- Repeated actions (submit twice, refresh during save)
- Partial failures (network drops mid-transaction)
- Concurrent usage (two tabs, two users, race conditions)

### Failure Imagination (CRITICAL)

For each area, testers MUST actively imagine:

1. **Worst-case failure** — How could this break in the most damaging way?
2. **Failure chain** — What sequence of events leads to that failure?
3. **Trigger conditions** — What combination of conditions would cause it?
4. **Blast radius** — Is the failure isolated or can it cascade?
5. **Degradation** — Does the system fail completely or degrade gracefully?

### Scenario Structure

Every test scenario must include:

```markdown
| Field                 | Content                             |
| --------------------- | ----------------------------------- |
| **Preconditions**     | System state before the test        |
| **Action**            | Exact steps to trigger the scenario |
| **Expected behavior** | What SHOULD happen                  |
| **Failure behavior**  | What happens if it breaks           |
| **Evidence**          | How to prove the finding            |
| **Impact**            | Users affected, business impact     |
```

## Phase 5: Validation & Proof

### Proof Requirement (MANDATORY)

Every finding MUST be supported by:

- A concrete scenario (not hypothetical)
- A clear chain of events (reproducible steps)
- A logical explanation of HOW the system breaks
- Code references (`file:line`) showing the vulnerability

If it cannot be demonstrated: **REJECT it**.

### Production Reality Check

For every issue, ask:

| Question                                     | If NO              |
| -------------------------------------------- | ------------------ |
| Can this realistically happen in production? | Deprioritize       |
| Under what real conditions?                  | Need more evidence |
| How often could this occur?                  | Adjust severity    |
| Does it affect real users?                   | May be info-only   |

### Leader Interrogation Protocol

For every finding, the leader MUST interrogate:

1. Why is this a real issue?
2. Under what exact conditions does it happen?
3. Show a concrete scenario
4. What breaks at scale?
5. What if conditions change?

If the tester cannot defend it: **REJECT it**.

## Phase 6: Impact Assessment

### Severity Classification

| Severity     | Criteria                                                 | Action                       |
| ------------ | -------------------------------------------------------- | ---------------------------- |
| **Critical** | Data loss, security breach, system crash, revenue impact | Must fix before production   |
| **High**     | Significant functionality broken, many users affected    | Should fix before production |
| **Medium**   | Edge case failures, workaround exists                    | Plan to fix                  |
| **Low**      | Minor UX issues, rare conditions                         | Backlog                      |
| **Info**     | Observations, potential future risks                     | Document only                |

### Impact Filtering

Reject or deprioritize findings that are:

- Vague or assumption-based
- Not grounded in realistic behavior
- Low user impact with no cascade potential
- Already mitigated by existing safeguards

## Phase 7: Final Judgment

### Production Readiness Decision

| Verdict         | Criteria                                                      |
| --------------- | ------------------------------------------------------------- |
| **SAFE**        | No critical/high issues, known risks are mitigated            |
| **CONDITIONAL** | High issues exist but have workarounds or mitigations planned |
| **UNSAFE**      | Critical issues found, system should NOT go to production     |

### Confidence Level

| Level      | Meaning                                                  |
| ---------- | -------------------------------------------------------- |
| **High**   | Deep analysis, good coverage, findings are well-defended |
| **Medium** | Reasonable coverage, some areas not fully explored       |
| **Low**    | Surface-level analysis, significant unknowns remain      |

### Unknown Risk Awareness

Always identify:

- Areas not fully understood
- Assumptions that could be wrong
- Parts of the system not deeply tested
- External dependencies not verified

These represent **hidden risks** that must be disclosed.

## Report Template

```markdown
## Production Testing Report: <system>

### System Understanding

- Purpose: <what it does>
- Users: <who uses it>
- Critical actions: <what matters most>

### Team Composition

| Role   | Focus  | Findings                     |
| ------ | ------ | ---------------------------- |
| <role> | <area> | N critical, N high, N medium |

### Risk Areas Identified

| Area   | Risk Level           | Coverage                  |
| ------ | -------------------- | ------------------------- |
| <area> | Critical/High/Medium | Tested/Partial/Not tested |

### Critical Findings

1. **[severity]** <finding> — **Evidence**: <proof> — **Impact**: <who/what affected>

### What Matters vs What Does Not

| Matters (test deeply) | Does Not Matter (skip/deprioritize) |
| --------------------- | ----------------------------------- |
| <item>                | <item>                              |

### Unknown Risks

- <area or assumption not verified>

### Final Judgment

- **Verdict**: SAFE / CONDITIONAL / UNSAFE
- **Confidence**: High / Medium / Low
- **Top risks**: <1-3 most critical risks>
- **Recommendation**: <specific next steps>
```
