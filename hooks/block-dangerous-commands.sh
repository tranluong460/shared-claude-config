#!/usr/bin/env bash
# PreToolUse hook: Block dangerous bash commands
# Reads tool input from stdin, checks command against denylist patterns

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command')

# Patterns to block
DANGEROUS_PATTERNS=(
  'rm\s+-rf\s+/'
  'rm\s+-rf\s+\.'
  'git\s+push\s+(-f|--force)'
  'git\s+push.*--force'
  'git\s+reset\s+--hard'
  'DROP\s+TABLE'
  'TRUNCATE'
  '--no-verify'
  '--dangerously'
  'chmod\s+777'
  'curl.*\|\s*bash'
  'curl.*\|\s*sh'
  'wget.*\|\s*bash'
  'wget.*\|\s*sh'
  '\beval\b.*\$'
)

# Join patterns with |
PATTERN=$(IFS='|'; echo "${DANGEROUS_PATTERNS[*]}")

if echo "$CMD" | grep -qiE "$PATTERN"; then
  echo "BLOCKED: Dangerous command detected: $CMD" >&2
  exit 2
fi
