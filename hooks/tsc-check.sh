#!/usr/bin/env bash
# PostToolUse hook: TypeScript type-check after Write/Edit/MultiEdit on .ts/.tsx files
# Informational only — never blocks (exit 0). Claude reads stderr/stdout and self-corrects.
# Optimized with --incremental for low latency.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty' 2>/dev/null)

# Only process .ts and .tsx files
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

if [[ "$FILE_PATH" != *.ts && "$FILE_PATH" != *.tsx ]]; then
  exit 0
fi

# Skip files outside the project (e.g., .claude/ edits)
if [[ "$FILE_PATH" == *".claude/"* ]]; then
  exit 0
fi

# Locate project root and tsc
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
TSC_BIN="$PROJECT_DIR/node_modules/.bin/tsc"

if [[ ! -x "$TSC_BIN" ]]; then
  # Fallback to global tsc if local missing — silent if neither exists
  if ! command -v tsc &>/dev/null; then
    exit 0
  fi
  TSC_BIN="tsc"
fi

if [[ ! -f "$PROJECT_DIR/tsconfig.json" ]]; then
  exit 0
fi

# Run incremental type-check, capture only errors (last 30 lines to avoid spam)
cd "$PROJECT_DIR" || exit 0
OUTPUT=$("$TSC_BIN" --noEmit --incremental --pretty false 2>&1 | tail -30)

# Only emit output if there are errors (tsc exits non-zero on errors)
if [[ -n "$OUTPUT" ]] && echo "$OUTPUT" | grep -qE "error TS[0-9]+"; then
  echo "[tsc-check] Type errors detected after editing $FILE_PATH:"
  echo "$OUTPUT"
fi

# Always exit 0 — informational hook, must not block edits
exit 0
