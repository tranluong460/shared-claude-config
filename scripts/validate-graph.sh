#!/usr/bin/env bash
# Validate command graph and workflow integrity
# Checks: command existence, result state consistency, workflow completeness
# Compatible with Git Bash on Windows (bash 4+, no yq/python)

set -euo pipefail

# --- Setup ---

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMMANDS_DIR="$BASE_DIR/commands"
WORKFLOWS_DIR="$BASE_DIR/workflows"

# Colors (with fallback)
if [[ -t 1 ]]; then
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  RED='\033[0;31m'
  BOLD='\033[1m'
  NC='\033[0m'
else
  GREEN='' YELLOW='' RED='' BOLD='' NC=''
fi

ERRORS=0
WARNINGS=0

pass()  { echo -e "  ${GREEN}[PASS]${NC} $1"; }
warn()  { echo -e "  ${YELLOW}[WARN]${NC} $1"; ((WARNINGS++)); }
fail()  { echo -e "  ${RED}[FAIL]${NC} $1"; ((ERRORS++)); }

# --- Parse Commands ---

declare -A CMD_STATES        # CMD_STATES[cmd_name]="state1 state2 state3"
declare -A CMD_NEXT_TARGETS  # CMD_NEXT_TARGETS[cmd_name]="target1 target2"
COMMAND_NAMES=()

for cmd_file in "$COMMANDS_DIR"/*.md; do
  [[ -f "$cmd_file" ]] || continue
  cmd_name=$(basename "$cmd_file" .md)
  COMMAND_NAMES+=("$cmd_name")

  # Extract YAML frontmatter (between first pair of ---)
  frontmatter=$(sed -n '/^---$/,/^---$/p' "$cmd_file" | sed '1d;$d')

  # Extract result_states: [a, b, c]
  states_line=$(echo "$frontmatter" | grep -E '^result_states:' || true)
  if [[ -n "$states_line" ]]; then
    states=$(echo "$states_line" | sed 's/result_states:[[:space:]]*\[//;s/\]//' | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    CMD_STATES["$cmd_name"]="$states"
  fi

  # Extract next_on_result targets (command names referenced)
  in_next=false
  targets=""
  while IFS= read -r line; do
    if echo "$line" | grep -qE '^next_on_result:'; then
      in_next=true
      continue
    fi
    if $in_next; then
      # Stop at next top-level key or end of frontmatter
      if echo "$line" | grep -qE '^[a-z]' && ! echo "$line" | grep -qE '^[[:space:]]'; then
        break
      fi
      # Extract command names from array values like "  clean: [refactor-plan, implement]"
      if echo "$line" | grep -qE '\[.*\]'; then
        cmds=$(echo "$line" | sed 's/.*\[//;s/\]//' | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        targets="$targets $cmds"
      fi
    fi
  done <<< "$frontmatter"
  CMD_NEXT_TARGETS["$cmd_name"]="$targets"
done

# --- Validate Command Graph ---

echo -e "\n${BOLD}=== Validating Command Graph ===${NC}\n"

for cmd_name in "${COMMAND_NAMES[@]}"; do
  targets="${CMD_NEXT_TARGETS[$cmd_name]:-}"
  if [[ -z "$targets" ]]; then
    pass "$cmd_name: no next_on_result targets (terminal)"
    continue
  fi

  all_valid=true
  missing=""
  for target in $targets; do
    [[ -z "$target" ]] && continue
    if [[ ! -f "$COMMANDS_DIR/$target.md" ]]; then
      all_valid=false
      missing="$missing $target"
    fi
  done

  if $all_valid; then
    pass "$cmd_name: all next_on_result targets exist"
  else
    fail "$cmd_name: missing command(s):$missing"
  fi
done

# --- Validate Workflows ---

echo -e "\n${BOLD}=== Validating Workflows ===${NC}\n"

for wf_file in "$WORKFLOWS_DIR"/*.yaml; do
  [[ -f "$wf_file" ]] || continue
  wf_name=$(basename "$wf_file")

  echo -e "  ${BOLD}$wf_name${NC}"

  # Extract top-level step command references (indented with exactly "  - command:")
  step_commands=$(grep -E '^  - command: /' "$wf_file" | sed 's/.*command: \///' | sed 's/[[:space:]]*$//')

  # Check each command exists
  all_exist=true
  for cmd in $step_commands; do
    if [[ ! -f "$COMMANDS_DIR/$cmd.md" ]]; then
      fail "  command /$cmd does not exist in commands/"
      all_exist=false
    fi
  done
  if $all_exist; then
    pass "  all commands exist"
  fi

  # For each step command, extract on_result keys using awk
  # Strategy: use awk to parse YAML structure instead of fragile while-read loop

  # Build a list of "command:key1,key2,key3" pairs from workflow YAML
  step_result_map=$(awk '
    /^  - command:/ {
      if (cmd != "" && keys != "") print cmd ":" keys
      cmd = $NF; gsub(/^\//, "", cmd); keys = ""
    }
    /^    on_result:/ { in_result = 1; next }
    in_result && /^      [a-z_]+:/ {
      key = $1; gsub(/:$/, "", key)
      keys = (keys == "" ? key : keys "," key)
    }
    in_result && /^  [^ ]/ && !/^      / { in_result = 0 }
    /^  - command:/ || /^[a-z]/ { in_result = 0 }
    END { if (cmd != "" && keys != "") print cmd ":" keys }
  ' "$wf_file")

  # Check each step's result coverage
  while IFS=: read -r cmd keys_csv; do
    [[ -z "$cmd" ]] && continue

    IFS=',' read -ra wf_keys <<< "$keys_csv"

    defined_states="${CMD_STATES[$cmd]:-}"
    if [[ -z "$defined_states" ]]; then
      warn "  /$cmd: no result_states defined in command frontmatter"
      continue
    fi

    # Check each on_result key is a valid state
    for key in "${wf_keys[@]}"; do
      if ! echo "$defined_states" | grep -qw "$key"; then
        fail "  /$cmd: on_result key '$key' is not in result_states"
      fi
    done

    # Check all defined states are handled
    while IFS= read -r state; do
      [[ -z "$state" ]] && continue
      found=false
      for key in "${wf_keys[@]}"; do
        if [[ "$key" == "$state" ]]; then
          found=true
          break
        fi
      done
      if ! $found; then
        warn "  /$cmd: result state '$state' has no handler in on_result"
      fi
    done <<< "$defined_states"

    pass "  /$cmd: result states checked"
  done <<< "$step_result_map"

  echo ""
done

# --- Summary ---

echo -e "${BOLD}=== Summary ===${NC}\n"
echo "  Commands: ${#COMMAND_NAMES[@]} checked"
echo "  Workflows: $(ls "$WORKFLOWS_DIR"/*.yaml 2>/dev/null | wc -l) checked"
echo "  Errors: $ERRORS"
echo "  Warnings: $WARNINGS"
echo ""

if [[ $ERRORS -gt 0 ]]; then
  echo -e "  ${RED}${BOLD}FAIL${NC}"
  exit 1
elif [[ $WARNINGS -gt 0 ]]; then
  echo -e "  ${YELLOW}${BOLD}PASS (with warnings)${NC}"
  exit 0
else
  echo -e "  ${GREEN}${BOLD}PASS${NC}"
  exit 0
fi
