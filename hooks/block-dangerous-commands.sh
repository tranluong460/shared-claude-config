#!/usr/bin/env bash
# PreToolUse hook: Block dangerous bash commands
# Reads tool input from stdin, checks command against denylist patterns

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command')

# Patterns to block
DANGEROUS_PATTERNS=(
  'rm\s+-rf\s+/'
  'rm\s+-rf\s+\.'
  '(/usr(/local)?/s?bin/)?git\s+push\s+(-f|--force)'
  '(/usr(/local)?/s?bin/)?git\s+push.*--force'
  '(/usr(/local)?/s?bin/)?git\s+reset\s+--hard'
  'DROP\s+TABLE'
  'TRUNCATE'
  '--no-verify'
  '--dangerously'
  '(/usr(/local)?/s?bin/)?chmod\s+777'
  '(/usr(/local)?/s?bin/)?curl.*\|\s*bash'
  '(/usr(/local)?/s?bin/)?curl.*\|\s*sh'
  '(/usr(/local)?/s?bin/)?wget.*\|\s*bash'
  '(/usr(/local)?/s?bin/)?wget.*\|\s*sh'
  '\beval\b.*\$'
  '(/usr(/local)?/s?bin/)?cat\s+.*\.(env|pem|key|crt|p12|pfx)'
  '(/usr(/local)?/s?bin/)?cat\s+.*(id_rsa|id_ed25519|id_ecdsa|authorized_keys|known_hosts)'
  '(/usr(/local)?/s?bin/)?cat\s+.*\.(aws|ssh|gnupg|kube|docker)'
  '(/usr(/local)?/s?bin/)?cat\s+.*credentials'
  '(/usr(/local)?/s?bin/)?cat\s+.*\.npmrc'
  '(/usr(/local)?/s?bin/)?cat\s+.*\.pypirc'
  '(/usr(/local)?/s?bin/)?cat\s+.*\.git-credentials'
  '/usr/bin/rm\s|/usr/local/bin/rm\s'
  '/usr/bin/git\s+push\s+--force'
  '(/usr(/local)?/s?bin/)?mkfs\s'
  '(/usr(/local)?/s?bin/)?dd\s+if='
  '>\s*/dev/sd'
  '(/usr(/local)?/s?bin/)?rm\s+.*\.claude/(skills|agents|commands|rules|hooks)'
)

# Join patterns with |
PATTERN=$(IFS='|'; echo "${DANGEROUS_PATTERNS[*]}")

if echo "$CMD" | grep -qiE "$PATTERN"; then
  echo "BLOCKED: Dangerous command detected: $CMD" >&2
  exit 2
fi
