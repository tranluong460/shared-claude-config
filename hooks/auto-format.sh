#!/usr/bin/env bash
# PostToolUse hook: Auto-format TypeScript files with Prettier after Write/Edit
# Reads tool input from stdin, runs prettier on .ts/.tsx files

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty')

# Only process .ts and .tsx files
if [[ -n "$FILE_PATH" ]] && [[ "$FILE_PATH" == *.ts || "$FILE_PATH" == *.tsx ]]; then
  # Prefer local prettier, fallback to global
  if [[ -f ./node_modules/.bin/prettier ]]; then
    ./node_modules/.bin/prettier --write "$FILE_PATH" > /dev/null 2>&1
  elif command -v prettier &>/dev/null; then
    prettier --write "$FILE_PATH" > /dev/null 2>&1
  fi
  # Silent if prettier not found — not all projects use it
fi
