#!/usr/bin/env bash
# UserPromptSubmit hook: Suggest relevant /commands based on user prompt keywords
# Reads user prompt from stdin, outputs suggestions if matching patterns found

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' | tr '[:upper:]' '[:lower:]')

if [[ -z "$PROMPT" ]]; then
  exit 0
fi

SUGGESTIONS=""

# Bug/error/debug keywords
if echo "$PROMPT" | grep -qiE '\b(bug|error|crash|fail|broken|fix|debug|trace|issue)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /diagnose \"<description>\" — investigate root cause"
fi

# Review/check keywords
if echo "$PROMPT" | grep -qiE '\b(review|check|quality|smell|code review)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /review <scope> — code quality review"
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
  SUGGESTIONS="$SUGGESTIONS\n  → /audit-naming <scope> — scan naming violations"
fi

# Documentation audit keywords
if echo "$PROMPT" | grep -qiE '\b(dead doc|unused doc|orphan|audit.?doc|doc.?consistency|doc.?audit|documentation.?(audit|check|unused|dead))\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /audit-docs — audit .claude/ documentation consistency"
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

# Reflection keywords
if echo "$PROMPT" | grep -qiE '\b(reflect|improve config|session review|lesson|pattern|what went wrong)\b'; then
  SUGGESTIONS="$SUGGESTIONS\n  → /reflect 1 week — analyze patterns and suggest config improvements"
fi

if [[ -n "$SUGGESTIONS" ]]; then
  echo -e "Available commands for this task:$SUGGESTIONS"
fi
