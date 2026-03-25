---
name: orchestration-contracts
description: Result state taxonomy, artifact schemas, workflow patterns, and state machine rules for multi-command pipelines.
layer: workflow
---

# Orchestration Contracts

Formal contracts governing how commands chain into workflows. For runtime classification logic during execution, see `agents/orchestrator.md`.

## 1. Result State Taxonomy

Each command category has canonical business-outcome states. These are **not** execution statuses — a command can execute successfully and still produce a non-success result.

| Category    | States                  | Meaning                                           | Expected Artifact                               |
| ----------- | ----------------------- | ------------------------------------------------- | ----------------------------------------------- |
| **audit**   | `clean`                 | No critical/major issues                          | `*-report` (empty issues list)                  |
|             | `issues_found`          | Critical or major issues detected                 | `*-report` (ranked issue list)                  |
|             | `execution_error`       | Tool failure, file not found                      | Error details                                   |
| **analyze** | `root_cause_found`      | Specific cause identified with evidence           | `diagnosis-report`                              |
|             | `insufficient_evidence` | Competing hypotheses, no clear winner             | Partial `diagnosis-report`                      |
|             | `execution_error`       | Tool failure during investigation                 | Error details                                   |
| **execute** | `success`               | Changes applied, verification passes              | `code-changes` / `test-files` / `documentation` |
|             | `validation_failed`     | Changes made but `flint`/`typecheck`/`test` fails | Partial changes + error output                  |
|             | `build_failed`          | Cannot compile or build                           | Build error output                              |
|             | `blocked`               | Missing dependency or unclear requirements        | Blocker description                             |
| **verify**  | `approved`              | No blocking issues (minor only acceptable)        | `review-report`                                 |
|             | `changes_requested`     | Critical/major issues need fixing                 | `review-report` (issue list)                    |
|             | `blocked`               | Cannot review (no diff, missing input)            | Blocker description                             |
| **plan**    | `plan_ready`            | Actionable plan with phases and verification      | `refactoring-plan`                              |
|             | `needs_input`           | Ambiguous scope, multiple valid approaches        | Partial plan + questions                        |
|             | `execution_error`       | Tool failure                                      | Error details                                   |
| **improve** | `insights_found`        | Actionable config improvement proposals           | `reflection-report`                             |
|             | `no_patterns`           | Clean history, nothing actionable                 | Summary `reflection-report`                     |
|             | `execution_error`       | Tool failure                                      | Error details                                   |

## 2. Artifact Schemas

What each artifact type must contain for downstream consumers to work correctly.

| Artifact              | Producer(s)                   | Consumer(s)                 | Required Content                                        |
| --------------------- | ----------------------------- | --------------------------- | ------------------------------------------------------- |
| `architecture-report` | /audit-project                | /refactor-plan              | Health score, issue list with severity, dependency map  |
| `review-report`       | /audit-code, /parallel-review | /implement                  | Severity-ranked issues with file:line, fix suggestions  |
| `naming-report`       | /audit-naming                 | /implement                  | Violation table with current/suggested/location         |
| `doc-audit-report`    | /audit-docs                   | /repair-docs                | Classification table (Active/Passive/Dead), issue list  |
| `diagnosis-report`    | /diagnose                     | /implement, /generate-tests | Root cause, evidence chain, recommended solutions       |
| `refactoring-plan`    | /refactor-plan                | /implement                  | Phased tasks, risk assessment, verification commands    |
| `code-changes`        | /implement                    | /parallel-review            | Changed files list, recipe used, verification results   |
| `test-files`          | /generate-tests               | /implement                  | Test file paths, pass/fail counts                       |
| `documentation`       | /generate-docs                | /audit-docs                 | Created/updated file paths, doc type                    |
| `reflection-report`   | /reflect                      | manual                      | Patterns found, config change proposals, lesson entries |
| `config-suggestions`  | /reflect                      | manual                      | Specific file edits for rules/skills/hooks              |

## 3. Workflow Patterns

### Linear Pipeline

```
A ──proceed──▶ B ──proceed──▶ C ──done
```

Use when: steps are sequential with no branching. Example: docs-repair (audit → repair → verify).

### Conditional Branch

```
A ──clean──▶ done
  ──issues_found──▶ B ──success──▶ A (verify)
```

Use when: result determines whether to continue or take corrective action. Example: audit → fix → re-audit.

### Error Recovery

```
A ──success──▶ B
  ──validation_failed──▶ C ──root_cause_found──▶ A (retry)
                           ──insufficient_evidence──▶ escalate
```

Use when: failures are diagnosable and potentially recoverable. Example: implement → diagnose → re-implement.

## 4. State Machine Rules

| Rule                       | Constraint                                                          | Rationale                                             |
| -------------------------- | ------------------------------------------------------------------- | ----------------------------------------------------- |
| `execution_error` handling | Must map to `escalate` or a diagnostic command                      | Tool failures need human attention or investigation   |
| `blocked` handling         | Must map to `escalate` or a planning command                        | Never `proceed` — blocked means missing prerequisites |
| Retry limit                | Max 1 retry per step per workflow run                               | Prevents infinite loops                               |
| Optional step skip         | Logged as `{"result": "skipped"}` — not a result state              | Keeps result_states clean for business outcomes only  |
| Terminal actions           | `done` and `escalate` end the workflow                              | No steps may follow a terminal action                 |
| Circular references        | A → B → A requires at least one `escalate` exit                     | Prevents unbounded loops                              |
| Artifact compatibility     | Producer's `produces` must include what consumer's `consumes` needs | Handoff fails silently if artifacts don't match       |

## 5. Pre-flight Validation Checklist

Before executing or adding a new workflow:

- [ ] Every step's `command` exists in `commands/`
- [ ] Every `on_result` key matches a value in the command's `result_states`
- [ ] Every result state from the command has a handler in `on_result`
- [ ] `execution_error` states map to `escalate` or `/diagnose`
- [ ] `blocked` states never map to `proceed`
- [ ] No circular step references without an `escalate` escape
- [ ] Artifact handoffs are compatible (`produces` ⊇ next step's `consumes`)
- [ ] Run `scripts/validate-graph.sh` to verify programmatically

## Quick Reference

| I want to...                                   | Look at...                                                     |
| ---------------------------------------------- | -------------------------------------------------------------- |
| Know what states a command can produce         | Section 1 (Result State Taxonomy)                              |
| Know what data to pass between steps           | Section 2 (Artifact Schemas)                                   |
| Design a new workflow                          | Section 3 (Workflow Patterns)                                  |
| Check if my workflow is valid                  | Section 5 (Pre-flight Checklist) + `scripts/validate-graph.sh` |
| Understand how to classify a result at runtime | `agents/orchestrator.md` → Result Classification Guide         |
