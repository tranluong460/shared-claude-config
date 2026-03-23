---
name: testing-methodology
description: 4-step analysis process for logic changes — Input Assumptions, Flow Analysis, Report, Implement.
layer: workflow
---

# Testing & Analysis Methodology (always active)

> Canonical process for analyzing and testing logic changes. Agents and commands reference here — do not duplicate.

## When to Apply

- Before implementing any logic change that affects data flow
- Before fixing bugs that involve state management or data transformation
- Before adding new features that interact with existing logic
- Before refactoring code that has multiple consumers

## Process Overview

```
Step 1: Input Assumptions --> Step 2: Flow Analysis --> Step 3: Report --> Step 4: Implement
```

**Do NOT skip to Step 4.** Each step must be completed before the next.

---

## Step 1: Input Assumptions

Goal: Enumerate all possible inputs and predict outcomes before touching code.

### Checklist

- [ ] List all input variables (params, state, config, environment)
- [ ] Identify value types and ranges for each variable
- [ ] Create input combination matrix
- [ ] Document expected output for each combination
- [ ] Identify edge cases and boundary conditions

### How to Execute

1. **List all input variables**

```
| Variable   | Type     | Possible Values              | Source          |
| ---------- | -------- | ---------------------------- | --------------- |
| proxyType  | enum     | HTTP, SOCKS5, NONE           | user config     |
| host       | string   | valid IP, domain, empty, null| payload         |
| port       | number   | 1-65535, 0, negative, NaN    | payload         |
| ...        | ...      | ...                          | ...             |
```

2. **Create input combination matrix** (focus on meaningful combinations, not all permutations)

```
| # | proxyType | host       | port  | Expected Output        | Side Effects     | Issues?          |
| - | --------- | ---------- | ----- | ---------------------- | ---------------- | ---------------- |
| 1 | HTTP      | "1.2.3.4"  | 8080  | Valid proxy connection  | None             | None             |
| 2 | HTTP      | ""         | 8080  | Error: invalid host    | None             | Need validation  |
| 3 | NONE      | null       | 0     | Direct connection      | Skip proxy setup | Check null guard  |
| 4 | SOCKS5    | "1.2.3.4"  | -1    | Error: invalid port    | None             | Need range check  |
```

3. **Flag edge cases**

- null / undefined / empty string inputs
- Boundary values (0, MAX_INT, empty array)
- Concurrent calls with same input
- Input that was valid in old logic but invalid in new logic

---

## Step 2: Original Flow Analysis

Goal: Understand the existing code before changing it. Prevent regressions.

### Checklist

- [ ] Trace the current execution flow step by step
- [ ] Document WHY each step exists (not just WHAT it does)
- [ ] Identify all callers / consumers of the code being changed
- [ ] If proposing changes, answer conflict questions below

### How to Execute

1. **Trace the flow**

```
1. Caller invokes functionX(params)
2. functionX validates params --> returns early if invalid
3. functionX calls serviceY.process(params)
4. serviceY reads from cache first --> falls back to API
5. Result is transformed by mapperZ
6. Result is returned to caller
```

2. **Document the WHY for each step**

```
| Step | Code                    | WHY it exists                          |
| ---- | ----------------------- | -------------------------------------- |
| 2    | Validate params         | Prevent invalid API calls downstream   |
| 4    | Cache-first strategy    | Reduce API rate limiting issues        |
| 5    | mapperZ transformation  | API response shape differs from domain |
```

3. **Conflict analysis** (required when proposing changes)

```
| Question                                        | Answer |
| ----------------------------------------------- | ------ |
| Does the change conflict with existing logic?    |        |
| Does it duplicate logic that already exists?     |        |
| Does it break any existing behavior?             |        |
| Are there other callers that depend on old flow? |        |
| Does it change the function signature/contract?  |        |
```

---

## Step 3: Detailed Report

Goal: Consolidate findings into a clear, actionable summary before implementing.

### Report Template

```markdown
### Analysis Report: <change description>

**Scope**: <files and functions affected>

#### Input Analysis Summary
- Total input combinations analyzed: N
- Edge cases identified: N
- Breaking combinations found: N (list them)

#### Flow Impact
- Current flow steps affected: <which steps change>
- Callers affected: <list files/functions>
- Backward compatible: Yes / No

#### Proposed Solution
- <Clear description of what to change and why>

#### Performance Considerations
- [ ] Does this add async operations to a sync path?
- [ ] Does this increase memory usage (caching, buffering)?
- [ ] Does this add network calls in a loop?
- [ ] Does this change O(n) complexity?

#### Affected Files
| File                    | Change Type        | Risk   |
| ----------------------- | ------------------ | ------ |
| src/core/proxy.ts       | Logic change       | Medium |
| src/utils/validator.ts  | New validation     | Low    |
| ...                     | ...                | ...    |

#### Risks
- <Risk 1>: <mitigation>
- <Risk 2>: <mitigation>
```

---

## Step 4: Implementation

Goal: Implement only after Steps 1-3 are complete and reviewed.

### Checklist

- [ ] Steps 1-3 are documented and reviewed
- [ ] Implement incrementally (one logical change at a time)
- [ ] Verify after each change (build, lint, test)
- [ ] Re-check input matrix from Step 1 against final implementation
- [ ] Confirm no regressions on existing callers from Step 2

### Implementation Order

1. Add validation / guards first
2. Implement core logic change
3. Update callers if needed
4. Verify edge cases from Step 1

---

## Quick Reference: Common Mistakes This Process Prevents

| Mistake                                    | Which step catches it |
| ------------------------------------------ | --------------------- |
| Missing null/undefined handling             | Step 1                |
| Breaking existing callers                   | Step 2                |
| Duplicating logic that already exists       | Step 2                |
| Performance regression                      | Step 3                |
| Implementing before understanding the problem | Step 1 + 2          |
| Fixing symptom instead of root cause        | Step 2                |
