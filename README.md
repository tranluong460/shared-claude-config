# Shared Claude Config

A reusable `.claude` toolkit for Node.js / TypeScript / Electron projects at production quality.

## What's Included

| Component | Count | Purpose |
|-----------|-------|---------|
| Commands | 10 | User-facing slash commands (`/review`, `/diagnose`, `/implement`, ...) |
| Agents | 7 | Specialized AI roles (architect, reviewer, debugger, ...) |
| Skills | 7 | Knowledge modules (coding standards, naming, testing, ...) |
| Rules | 11 | Path-scoped enforcement (auto-injected by file path) |
| Hooks | 5 | Automated quality gates (format, block, suggest, verify) |

## Quick Start

1. Copy `.claude/` directory into your project root
2. Copy `CLAUDE.md` to your project root (customize for your project)
3. Optionally copy `tasks/` for task tracking templates

```bash
# Or symlink for shared use across projects
ln -s /path/to/shared-claude-config/.claude .claude
```

## Usage

```
/review src/modules/user        # Code quality review
/diagnose "Error X when Y"      # Bug investigation
/implement "add auth module"     # Recipe-based implementation
/generate-tests src/auth.ts     # Generate tests
/parallel-review latest         # Independent review (no bias)
/reflect 1 week                 # Analyze patterns, improve config
```

## Documentation

See [`.claude/README.md`](.claude/README.md) for full architecture, workflow diagrams, and customization guide.

## Config Layers

| File | Scope | Committed? |
|------|-------|------------|
| `.claude/settings.json` | Team-shared config (permissions, hooks) | Yes |
| `.claude/settings.local.json` | Personal overrides | No (gitignored) |
| `CLAUDE.md` | Project instructions | Yes |
| `CLAUDE.local.md` | Personal instructions | No (gitignored) |

## License

See [LICENSE](LICENSE).
