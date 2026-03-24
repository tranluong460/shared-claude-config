#!/usr/bin/env bash
# PostToolUse hook: Log command invocations to memory/command-history.jsonl
# Triggers after Bash tool use, detects /command patterns in tool output

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Only process after tool completions that might indicate command execution
if [[ "$TOOL_NAME" != "Bash" && "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

# Check if output contains command execution markers
OUTPUT=$(echo "$INPUT" | jq -r '.tool_input // empty')

# Detect slash command patterns in recent context
COMMAND=""
if echo "$OUTPUT" | grep -qiE '(executing|running).*/(audit-code|audit-naming|audit-project|audit-docs|diagnose|refactor-plan|generate-tests|generate-docs|implement|parallel-review|reflect|repair-docs)'; then
  COMMAND=$(echo "$OUTPUT" | grep -oiE '/(audit-code|audit-naming|audit-project|audit-docs|diagnose|refactor-plan|generate-tests|generate-docs|implement|parallel-review|reflect|repair-docs)' | head -1)
fi

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Determine the log directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_DIR="$SCRIPT_DIR/../memory"
LOG_FILE="$MEMORY_DIR/command-history.jsonl"

# Ensure memory directory exists
mkdir -p "$MEMORY_DIR"

# Get timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Append log entry
echo "{\"timestamp\":\"$TIMESTAMP\",\"command\":\"$COMMAND\",\"tool\":\"$TOOL_NAME\"}" >> "$LOG_FILE"
