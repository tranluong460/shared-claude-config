#!/usr/bin/env bash
# PostCompact hook: Re-inject critical context after context compaction
# After compaction, Claude loses conversation-specific decisions and nuance.
# This hook restores the most important context to prevent rule violations.

echo "=== CONTEXT RESTORED AFTER COMPACTION ==="
echo ""

# --- Critical Rules (non-negotiable) ---
echo "CRITICAL RULES (always follow):"
echo "- No 'any' type. Use specific types. Return types required."
echo "- Max 50 lines per function. Max 300 lines per file."
echo "- Naming: E prefix (enums), I prefix (interfaces/types), verb-first functions, kebab-case files."
echo "- IPC changes = update ALL layers: types > handler > preload > API > hook"
echo "- Verify: npm run flint > npm run typecheck before declaring done."
echo "- Package: yarn install/add for dependencies, npm run for scripts."
echo ""

# --- Self-improvement reminder ---
echo "SELF-IMPROVEMENT: When user corrects you, append lesson to .claude/memory/lessons.md"
echo ""

# --- Active tasks (if task tools are in use) ---
echo "CHECK: Use TaskList to see if there are active tasks from before compaction."
echo ""

# --- Recently modified files in this session ---
MODIFIED=$(git diff --name-only HEAD 2>/dev/null | head -10)
if [[ -n "$MODIFIED" ]]; then
  echo "RECENTLY MODIFIED FILES (uncommitted changes):"
  echo "$MODIFIED"
  echo ""
fi

# --- Current branch context ---
BRANCH=$(git branch --show-current 2>/dev/null)
if [[ -n "$BRANCH" ]]; then
  echo "CURRENT BRANCH: $BRANCH"
  RECENT_COMMITS=$(git log --oneline -3 2>/dev/null)
  if [[ -n "$RECENT_COMMITS" ]]; then
    echo "RECENT COMMITS:"
    echo "$RECENT_COMMITS"
  fi
  echo ""
fi

# --- Stale /reflect banner (before injecting lessons so it's prominent) ---
if [[ -f ".claude/memory/lessons.md" ]]; then
  # Portable mtime: try GNU stat then BSD stat. Default to "fresh" if both fail.
  LESSONS_MTIME=$(stat -c '%Y' ".claude/memory/lessons.md" 2>/dev/null || stat -f '%m' ".claude/memory/lessons.md" 2>/dev/null || echo "")
  if [[ -n "$LESSONS_MTIME" ]]; then
    NOW=$(date +%s)
    AGE_DAYS=$(( (NOW - LESSONS_MTIME) / 86400 ))
    if [[ "$AGE_DAYS" -gt 7 ]]; then
      echo "================================================"
      echo "TIME TO RUN /reflect — lessons.md is $AGE_DAYS days old"
      echo "Self-improvement loop is stale. Surface this to the user:"
      echo "  → /reflect 1 week"
      echo "Precedent: lessons.md 2026-03-31 'Self-improvement loop was broken'"
      echo "================================================"
      echo ""
    fi
  fi
fi

# --- Recent lessons (inject content directly, not just count) ---
if [[ -f ".claude/memory/lessons.md" ]]; then
  LESSON_COUNT=$(grep -c '^### ' ".claude/memory/lessons.md" 2>/dev/null || echo "0")
  if [[ "$LESSON_COUNT" -gt 0 ]]; then
    echo "RECENT LESSONS ($LESSON_COUNT total):"
    # Inject last 15 lines of lessons — Claude reads these directly after compaction
    tail -15 ".claude/memory/lessons.md" 2>/dev/null
    echo ""
  fi
fi

echo ""
echo "TIP: If you lost track of what you were doing, ask the user or check TaskList."
echo "RULES: .claude/rules/ | SKILLS: .claude/skills/ | COMMANDS: /help"
