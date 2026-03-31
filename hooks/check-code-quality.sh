#!/usr/bin/env bash
# PostToolUse hook: Enforce critical code quality rules after Write/Edit on .ts/.tsx files
# Exit code 2 = block + inject warning into Claude's context (Claude will self-correct)
# This turns advisory rules into LAW — Claude follows hooks 100% of the time

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty')

# Only check .ts and .tsx files (not .d.ts)
if [[ -z "$FILE_PATH" ]]; then exit 0; fi
if [[ "$FILE_PATH" == *.d.ts ]]; then exit 0; fi
if [[ "$FILE_PATH" != *.ts && "$FILE_PATH" != *.tsx ]]; then exit 0; fi
if [[ ! -f "$FILE_PATH" ]]; then exit 0; fi

VIOLATIONS=""

# --- Rule 1: No `any` type ---
# Match `: any`, `as any`, `<any>`, but skip comments and strings
ANY_MATCHES=$(grep -nE ':\s*any\b|as\s+any\b|<any>' "$FILE_PATH" | grep -v '^\s*//' | grep -v '//.*any' | head -5)
if [[ -n "$ANY_MATCHES" ]]; then
  VIOLATIONS="$VIOLATIONS\n  VIOLATION: 'any' type detected — use specific types instead:\n$ANY_MATCHES"
fi

# --- Rule 2: No console.log (use proper logging) ---
# Skip test files and config files
if [[ "$FILE_PATH" != *.test.ts && "$FILE_PATH" != *.spec.ts ]]; then
  CONSOLE_MATCHES=$(grep -nE '\bconsole\.(log|warn|error|debug|info)\b' "$FILE_PATH" | grep -v '^\s*//' | head -5)
  if [[ -n "$CONSOLE_MATCHES" ]]; then
    VIOLATIONS="$VIOLATIONS\n  VIOLATION: console.log detected — use proper logging or remove:\n$CONSOLE_MATCHES"
  fi
fi

# --- Rule 3: Functions over 50 lines ---
# Simple heuristic: count lines between function/method declarations
# This catches obvious violations, not a full AST parse
LONG_FN=$(awk '
  /^[[:space:]]*(export )?(async )?(function |const [a-zA-Z]+ = (async )?\()/ || /^[[:space:]]*(public |private |protected )?(async )?[a-zA-Z]+\(/ {
    if (start > 0 && NR - start > 50) {
      printf "  Line %d: function starting here is >50 lines (%d lines)\n", start, NR - start
    }
    start = NR
  }
  END {
    if (start > 0 && NR - start > 50) {
      printf "  Line %d: function starting here is >50 lines (%d lines)\n", start, NR - start
    }
  }
' "$FILE_PATH")
if [[ -n "$LONG_FN" ]]; then
  VIOLATIONS="$VIOLATIONS\n  VIOLATION: Function exceeds 50-line limit:\n$LONG_FN"
fi

# --- Rule 4: File over 300 lines ---
LINE_COUNT=$(wc -l < "$FILE_PATH" 2>/dev/null | tr -d ' ')
if [[ "$LINE_COUNT" -gt 300 ]]; then
  VIOLATIONS="$VIOLATIONS\n  VIOLATION: File has $LINE_COUNT lines (max 300) — consider splitting"
fi

# --- Output violations ---
if [[ -n "$VIOLATIONS" ]]; then
  echo -e "CODE QUALITY CHECK FAILED for $FILE_PATH:$VIOLATIONS" >&2
  echo -e "\nFix these violations before proceeding. Rules: .claude/rules/code-quality.md" >&2
  # Hard block for `any` type (most critical rule), warn for others
  if [[ -n "$ANY_MATCHES" ]]; then
    exit 2
  fi
  exit 0
fi
