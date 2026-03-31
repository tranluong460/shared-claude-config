#!/usr/bin/env bash
# UserPromptSubmit hook: Suggest relevant /commands based on user prompt keywords
# Reads user prompt from stdin, outputs suggestions if matching patterns found

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' | tr '[:upper:]' '[:lower:]')

if [[ -z "$PROMPT" ]]; then
  exit 0
fi

# Skip short prompts and slash commands
if [ ${#PROMPT} -lt 10 ]; then exit 0; fi
if [[ "$PROMPT" == /* ]]; then exit 0; fi

SUGGESTIONS=""

# Bug/error/debug keywords
if echo "$PROMPT" | grep -qiE '\b(bug|error|crash|fail|broken|fix|debug|trace|issue)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /diagnose \"<description>\" — investigate root cause"
fi

# Review/check keywords
if echo "$PROMPT" | grep -qiE '\b(review|check|quality|smell|code review)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /audit-code <scope> — code quality review"
fi

# Architecture/audit keywords
if echo "$PROMPT" | grep -qiE '\b(architecture|structure|health|project audit|full audit|dependency)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /audit-project — full architecture audit with health score"
fi

# Refactor keywords
if echo "$PROMPT" | grep -qiE '\b(refactor|restructure|reorganize|clean.?up|extract)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /refactor-plan <scope> — create phased plan first"
fi

# Test keywords
if echo "$PROMPT" | grep -qiE '\b(test|spec|coverage|mock|assert)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /generate-tests <file> — plan and generate tests"
fi

# Doc keywords
if echo "$PROMPT" | grep -qiE '\b(doc|readme|adr|changelog|document)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /generate-docs <type> — create documentation"
fi

# Naming keywords
if echo "$PROMPT" | grep -qiE '\b(naming|rename|convention|prefix)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /audit-code naming <scope> — deep naming audit"
fi

# Documentation audit keywords
if echo "$PROMPT" | grep -qiE '\b(dead doc|unused doc|orphan|audit.?doc|doc.?consistency|doc.?audit|documentation.?(audit|check|unused|dead))\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /audit-config — audit .claude/ documentation consistency"
fi

# Documentation repair keywords
if echo "$PROMPT" | grep -qiE '\b(fix doc|repair doc|sync doc|doc.?repair|doc.?fix|fix.?unused)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /repair-config — fix documentation issues found by /audit-config"
fi

# Logic and flow analysis
if echo "$PROMPT" | grep -qiE '\b(logic|flow|data.?flow|state.?manag|edge.?case|race.?condition)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /diagnose \"<description>\" — investigate logic/flow issue"
fi

# Confusion or unexpected behavior
if echo "$PROMPT" | grep -qiE '\b(không hiểu|unexpected|weird|why.*(not|does|is)|tại sao|confus)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /diagnose \"<description>\" — investigate unexpected behavior"
fi

# Implement keywords
if echo "$PROMPT" | grep -qiE '\b(implement|build|create|add feature|new feature)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /implement \"<task>\" — recipe-based implementation"
fi

# Independent review keywords
if echo "$PROMPT" | grep -qiE '\b(independent review|fresh eyes|worktree|parallel review|second opinion)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /parallel-review latest — independent review in isolated worktree"
fi

# Production testing keywords
if echo "$PROMPT" | grep -qiE '\b(production test|readiness|ship|safe to deploy|risk assess|failure scenario|production ready|stress test|system test)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /test-system <scope> — multi-agent production readiness analysis"
fi

# Reflection keywords
if echo "$PROMPT" | grep -qiE '\b(reflect|improve config|session review|lesson|pattern|what went wrong)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /reflect 1 week — analyze patterns and suggest config improvements"
fi

# --- Post-action suggestions based on result semantics ---
# These match result states from command frontmatter (result_states + next_on_result)

# After implement → success: suggest generate-tests THEN parallel-review
if echo "$PROMPT" | grep -qiE '\b(done implement|implementation (done|complete|finished)|just implemented|finished (coding|building|implementing)|changes (applied|made|committed)|xong rồi|xong|hoàn thành)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /generate-tests <file> — add tests for changed logic (DO THIS FIRST)"
  SUGGESTIONS="$SUGGESTIONS\n  → /parallel-review latest — independent review of your changes"
fi

# After implement → validation_failed/build_failed: suggest diagnose
if echo "$PROMPT" | grep -qiE '\b(build (failed|broken|error)|typecheck (failed|error)|flint (failed|error)|validation (failed|error)|tests? (failed|failing))\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /diagnose \"<error>\" — investigate the failure"
fi

# After parallel-review → approved: suggest generate-docs, reflect
if echo "$PROMPT" | grep -qiE '\b(review (passed|clean|looks good|approved)|lgtm|no issues found|all checks passed)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /generate-docs <type> — document what changed"
  SUGGESTIONS="$SUGGESTIONS\n  → /reflect 1 week — analyze patterns and improve"
fi

# After parallel-review → changes_requested: suggest implement
if echo "$PROMPT" | grep -qiE '\b(review (failed|found issues|found problems|requested changes)|needs (fixes|changes)|changes requested|problems found)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /implement \"fix review issues\" — address review findings"
fi

# After diagnose → root_cause_found: suggest generate-tests, implement
if echo "$PROMPT" | grep -qiE '\b(found (the bug|root cause|the issue)|diagnosis (complete|done)|identified (the|root) cause|root cause.*(is|was|found))\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /generate-tests <file> — add regression test"
  SUGGESTIONS="$SUGGESTIONS\n  → /implement \"fix <issue>\" — apply the fix"
fi

# After diagnose → insufficient_evidence: suggest audit-code, audit-project
if echo "$PROMPT" | grep -qiE '\b(insufficient evidence|unclear|cannot determine|not enough (data|info|evidence)|need more (context|info|data))\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /audit-code <scope> — gather more code quality data"
  SUGGESTIONS="$SUGGESTIONS\n  → /audit-project — broader architecture analysis"
fi

# After generate-tests → success: suggest implement
if echo "$PROMPT" | grep -qiE '\b(tests (generated|created|added|passing)|test generation (done|complete))\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /implement \"<task>\" — proceed with implementation"
fi

# After generate-docs → success: suggest audit-config
if echo "$PROMPT" | grep -qiE '\b(docs? (generated|created|written)|documentation (done|complete|generated))\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /audit-config — verify documentation consistency"
fi

# After audit-* → issues_found: suggest appropriate fix
if echo "$PROMPT" | grep -qiE '\b(audit found|issues (detected|found)|doc.*(issues|problems) found|critical issues|major issues)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /repair-config — fix documentation issues (if doc audit)"
  SUGGESTIONS="$SUGGESTIONS\n  → /implement \"fix <issues>\" — fix code issues (if code audit)"
fi

# After audit-* → clean: suggest next in workflow
if echo "$PROMPT" | grep -qiE '\b(audit (clean|passed)|no issues|all (clean|good|passed)|zero (issues|violations|problems))\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /reflect 1 week — capture what went well"
fi

# After test-system → unsafe/conditional: suggest diagnose, implement, refactor-plan
if echo "$PROMPT" | grep -qiE '\b(verdict.*(unsafe|conditional)|unsafe.*verdict|not (safe|ready) for production|critical (findings|issues|risks)|production.*unsafe)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /diagnose \"<finding>\" — investigate critical finding"
  SUGGESTIONS="$SUGGESTIONS\n  → /implement \"fix <issue>\" — fix critical issues"
  SUGGESTIONS="$SUGGESTIONS\n  → /refactor-plan <scope> — plan structural improvements"
fi

# Workflow execution suggestion
if echo "$PROMPT" | grep -qiE '\b(new feature|feature request|start (feature|workflow)|run workflow|execute workflow)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → Run feature-delivery workflow: start with /audit-project"
fi

if echo "$PROMPT" | grep -qiE '\b(bug report|bug fix|fix bug|unexpected behavior|production (bug|issue))\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → Run bug-fix workflow: start with /diagnose \"<description>\""
fi

if [[ -n "$SUGGESTIONS" ]]; then
  echo -e "Available commands for this task:$SUGGESTIONS"
fi
