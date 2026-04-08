---
name: audit-config
description: Semantic auditing of .claude/ config — goes beyond path-grep to verify contracts between commands, agents, skills, rules, and hooks. Used by /audit config.
layer: core
---

# Audit Config — Semantic Checks

## Header Warning

> **A clean audit is necessary but NOT sufficient.**
>
> Static path-grep auditing (checking that file X references path Y) cannot verify semantic contracts. Specifically, it cannot detect:
>
> - An agent's `## Output Format` section emitting a single file when the invoking command mandates a folder.
> - A skill's template contradicting a rule the command loads.
> - A hook's matcher regex missing a keyword the command documentation says it handles.
>
> After any change to `.claude/`, **manually spot-read the delegate-agent output sections** against their invoking command's output rule. The 2026-04-07 session is the precedent: audit passed clean while 7 real issues remained, including one critical semantic contradiction.

## What this skill covers

1. **Semantic contracts** — invariants that path-grep cannot verify. Enumerated in `contract-checks.md`.
2. **Coverage transparency** — every audit run must emit an "Audit Coverage Report" listing which invariants were checked and which were NOT.
3. **Spot-read discipline** — after static checks pass, rotate through a short list of manually-verified files and report which ones were read.

## Audit levels

| Level            | What it checks                                                                                  | When to use                                            |
| ---------------- | ----------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| **L1 Static**    | File existence, path references, dead docs, unused integrations                                 | Every run — cheap                                      |
| **L2 Semantic**  | Command ↔ agent output contracts, skill templates vs rules, hook regex coverage                 | Every run — delegate to checks in `contract-checks.md` |
| **L3 Spot-read** | Manually read `## Output Format` of every agent invoked by a command changed in the last commit | On-demand after sync cycles                            |

Levels are cumulative — L2 requires L1 pass, L3 requires L2 pass. A "clean" verdict requires all three to have been attempted and reported.

## Required output sections

Every `/audit config` run MUST include these sections, in this order:

1. **Inventory Summary** (counts table)
2. **Issues Found** (table; empty if none)
3. **Pipeline Verification** (command → agent → skill chains)
4. **Semantic Contract Check** — per `contract-checks.md` (new; required)
5. **Audit Coverage Report** — lists: files scanned (count), invariants checked (count/list), invariants NOT checked (list with reasons)
6. **Recommendations** (priority-ordered)

If any of these sections is missing, the audit is incomplete and must not be reported as clean.

## Spot-read checklist (after static/semantic passes)

When a command file was changed in the last commit, read these before trusting clean:

- The command's `## Output` / Step that writes files
- Every agent the command delegates to — specifically their `## Output Format` / `## Output Formats` section
- Every skill the command loads — specifically any template that matches the output type
- Every rule the command references — specifically any path/folder convention

Report which files were spot-read in the Audit Coverage Report.

## Related

- `contract-checks.md` — enumerated semantic invariants (this skill's companion)
- `.claude/rules/no-unused-docs.md` — the dead-doc rule
- `.claude/rules/documentation.md` — Command ↔ Agent output contract invariant
- `.claude/commands/audit.md` — the unified audit command that loads this skill (subcommand `config`)
