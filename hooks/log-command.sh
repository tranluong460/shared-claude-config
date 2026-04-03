#!/usr/bin/env bash
# UserPromptSubmit hook: Log slash command invocations to memory/command-history.jsonl
# Fires on every user prompt — only logs when prompt starts with a known /command

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

if [[ -z "$PROMPT" ]]; then
  exit 0
fi

# Only match slash commands (prompts starting with /)
if [[ "$PROMPT" != /* ]]; then
  exit 0
fi

# Extract command name (first word after /)
COMMAND=$(echo "$PROMPT" | grep -oE '^/[a-z][a-z0-9-]*' | head -1)

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Strip the leading / for matching
CMD_NAME="${COMMAND#/}"

# Only log known commands
KNOWN_COMMANDS="audit-code audit-project audit-config diagnose refactor-plan generate-tests generate-docs implement impact-guard parallel-review test-system reflect repair-config"

FOUND=false
for known in $KNOWN_COMMANDS; do
  if [[ "$CMD_NAME" == "$known" ]]; then
    FOUND=true
    break
  fi
done

if ! $FOUND; then
  exit 0
fi

# Extract arguments (everything after the command name)
ARGS=$(echo "$PROMPT" | sed "s|^$COMMAND[[:space:]]*||")

# Determine log file path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_DIR="$SCRIPT_DIR/../memory"
LOG_FILE="$MEMORY_DIR/command-history.jsonl"

# Ensure memory directory exists
mkdir -p "$MEMORY_DIR"

# Get timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Append log entry
if [[ -n "$ARGS" ]]; then
  echo "{\"timestamp\":\"$TIMESTAMP\",\"command\":\"$COMMAND\",\"args\":\"$ARGS\"}" >> "$LOG_FILE"
else
  echo "{\"timestamp\":\"$TIMESTAMP\",\"command\":\"$COMMAND\"}" >> "$LOG_FILE"
fi
