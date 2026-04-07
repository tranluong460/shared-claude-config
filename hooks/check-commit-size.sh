#!/usr/bin/env bash
# PreToolUse(Bash) hook: Block mega-commits (>THRESHOLD staged files)
#
# Threshold starts at 50 (nới cho working tree đang có ~113 files).
# Tighten to 20 after current mega-tree is committed.
#
# Override mechanisms (in priority order):
#   1. Env: SPLIT_OK=1 git commit ...
#   2. Commit message contains [mega-ok] tag
#   3. --amend on existing commit (already past the gate)
#
# Precedent: lessons.md 2026-03-31 (mega-commit pattern) and 2026-04-07
# ("mega-commit pattern now 2-for-2; advisory rules insufficient").

set -u

THRESHOLD=50

# Read hook input (JSON on stdin).
# Parse with jq if available; fall back to pure-bash regex otherwise
# (jq is NOT guaranteed to be installed on all dev machines).
INPUT=$(cat)
if command -v jq >/dev/null 2>&1; then
  CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
  # Fallback: extract "command":"..." value. The harness JSON is well-formed
  # and escapes embedded quotes as \", so this regex is safe for our purpose.
  CMD=$(echo "$INPUT" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(\([^"\\]\|\\.\)*\)".*/\1/p' | head -1)
fi

# Not a bash command? Nothing to do.
if [[ -z "$CMD" ]]; then
  exit 0
fi

# Fast-path: not a git commit invocation
if ! echo "$CMD" | grep -qE '(^|[[:space:]&;|])git[[:space:]]+commit([[:space:]]|$)'; then
  exit 0
fi

# Skip amends — already past the size gate
if echo "$CMD" | grep -qE '\-\-amend'; then
  exit 0
fi

# Override 1: explicit env flag in the command
if echo "$CMD" | grep -qE 'SPLIT_OK=1'; then
  exit 0
fi

# Override 2: [mega-ok] tag in commit message
# Match both -m "..." and -m '...' and heredoc patterns
if echo "$CMD" | grep -qiE '\[mega-ok\]'; then
  exit 0
fi

# Count staged files
STAGED=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d '[:space:]')

if [[ -z "$STAGED" || "$STAGED" == "0" ]]; then
  # No staged changes — let git complain itself
  exit 0
fi

if [[ "$STAGED" -gt "$THRESHOLD" ]]; then
  cat >&2 <<EOF
BLOCKED: Mega-commit detected — $STAGED staged files exceeds threshold of $THRESHOLD.

Precedent (lessons.md):
  - 2026-03-31: 56/118/188-file commits were flagged as a recurring pattern
  - 2026-04-07: pattern repeated, promoted from advisory rule to enforced hook

How to proceed (pick one):
  1. Split the work into smaller logical commits:
       git reset HEAD
       git add <file1> <file2> ...   # one logical change at a time
       git commit -m "..."
       # repeat
  2. Override (only when the bundle is genuinely atomic):
       SPLIT_OK=1 git commit -m "..."
     OR include [mega-ok] in the commit message:
       git commit -m "refactor: massive sync [mega-ok]"

If you disagree with the threshold ($THRESHOLD), update:
  .claude/hooks/check-commit-size.sh  (THRESHOLD=...)
EOF
  exit 2
fi

exit 0
