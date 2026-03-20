---
name: refactoring-strategy
description: Refactoring techniques, strategy selection, risk assessment, and incremental approach for Node.js / Electron / module-based library projects. Includes Electron-specific and provider pattern recipes.
---

# Refactoring Strategy for Node.js / TypeScript / Electron

## Core Principle

> Refactoring changes **structure** without changing **behavior**.
> Every refactoring step must keep tests green.

## When to Refactor

| Trigger                  | Signal                                   | Priority               |
| ------------------------ | ---------------------------------------- | ---------------------- |
| Before adding a feature  | Hard to add cleanly to current structure | **High**               |
| After bug fix            | Root cause was structural                | **High**               |
| Code review findings     | Anti-patterns detected                   | Medium                 |
| Tech debt accumulation   | Velocity decreasing                      | Medium                 |
| Dependency upgrade       | Breaking changes require restructuring   | Medium                 |
| Performance optimization | Profiling shows bottleneck               | Low (data-driven only) |

## Strategy Selection

### 1. Surgical Refactor (Small — 1-3 files)

**When**: Fix isolated code smells within a module.

**Techniques**:

- Extract function / Extract variable
- Rename for clarity
- Replace conditional with polymorphism
- Introduce parameter object (3+ params → options object)
- Remove dead code

**Process**: Fix → Test → Commit. Repeat.

### 2. Module Refactor (Medium — 3-10 files)

**When**: Restructure a feature module or fix layering violations.

**Techniques**:

- Extract module (split large file into focused modules)
- Introduce interface (decouple concrete dependencies)
- Apply repository pattern (extract data access)
- Consolidate duplicates (Rule of Three confirmed)

**Process**:

1. Write characterization tests for current behavior
2. Refactor in small steps (each step keeps tests green)
3. Verify no behavior change
4. Update imports and re-export if needed

### 3. Architecture Refactor (Large — 10+ files)

**When**: Change project structure, migrate patterns, or replace major dependencies.

**Techniques**:

- Strangler Pattern: Gradually replace old implementation with new
- Facade Pattern: Add abstraction layer, swap implementation behind it
- Branch by Abstraction: Introduce interface, implement old + new, switch

**Process**:

1. Create ADR documenting the decision
2. Create Design Doc with phased plan
3. Set up parallel implementation (old + new coexist)
4. Migrate consumers incrementally
5. Remove old implementation after full migration
6. Verify with integration tests at each phase

## Risk Assessment

Before starting any refactoring, assess:

| Factor            | Low Risk      | Medium Risk       | High Risk        |
| ----------------- | ------------- | ----------------- | ---------------- |
| Test coverage     | > 80%         | 50-80%            | < 50%            |
| Files affected    | 1-3           | 4-10              | 10+              |
| Public API change | None          | Additive only     | Breaking         |
| Data migration    | None          | Schema-compatible | Schema change    |
| Rollback ability  | Simple revert | Partial revert    | Complex rollback |

**Rule**: If risk is High on 2+ factors → create ADR and get approval before starting.

## Incremental Approach

### Never Refactor Everything at Once

```
BAD:  Feature A + Feature B + Feature C → Big Bang refactor → 🔥
GOOD: Feature A → Test → Merge → Feature B → Test → Merge → Feature C → Test → Merge
```

### Phase Pattern

```
Phase 1: Add tests for current behavior (safety net)
Phase 2: Refactor structure (tests stay green)
Phase 3: Remove old code (tests still green)
Phase 4: Verify in production
```

## Common Refactoring Recipes

### Recipe 1: Extract Module from God File

```
Before: src/utils.ts (500 lines, 20 functions)

Step 1: Identify clusters by responsibility
Step 2: Create focused modules:
  - src/utils/date.util.ts
  - src/utils/string.util.ts
  - src/utils/validation.util.ts
Step 3: Move functions with their tests
Step 4: Update imports across project
Step 5: Delete original file
Step 6: Verify all tests pass
```

### Recipe 2: Introduce Dependency Injection

```
Before: class UserService { repo = new UserRepo() }

Step 1: Define interface for dependency
Step 2: Accept dependency via constructor
Step 3: Create factory function for production wiring
Step 4: Update tests to inject mocks
Step 5: Verify behavior unchanged
```

### Recipe 3: Replace Callback with Async/Await

```
Before: function readFile(path, callback) { ... }

Step 1: Create async wrapper around callback version
Step 2: Migrate callers one by one to use wrapper
Step 3: Rewrite core to native async when all callers migrated
Step 4: Delete callback version and wrapper
```

### Recipe 4: Consolidate Duplicate Code

```
Trigger: Same pattern found 3+ times

Step 1: Identify the common pattern
Step 2: Design the shared abstraction
Step 3: Create shared function/class
Step 4: Replace first duplicate → test
Step 5: Replace second duplicate → test
Step 6: Replace third duplicate → test
```

## Electron-Specific Recipes

### Recipe 5: Migrate IPC Channel

When renaming or restructuring an IPC channel:

> IPC layer sync steps: follow `.claude/rules/ipc.md` (all 8 layers must sync)

**Key rule**: Old and new channels coexist during migration. Never remove old before all callers are migrated.

### Recipe 6: Restructure Entity

When changing a TypeORM entity:

```
Step 1: Add new columns (nullable, with defaults) — non-breaking
Step 2: Migrate existing data in a subscriber or init script
Step 3: Update model methods to use new columns
Step 4: Update IPC handlers to accept/return new fields
Step 5: Update preload types and proxies
Step 6: Update renderer to use new fields
Step 7: Remove old columns (if no longer needed)
Step 8: Verify: npm run typecheck
```

**Key rule**: Always add columns as nullable first, migrate data, then make required.

### Recipe 7: Extract Service from IPC Handler

When an IPC handler becomes too large (100+ lines, per `.claude/rules/ipc.md`):

```
Before: src/main/ipc/account.ts (all logic inline in handlers)
After:  src/main/ipc/account.ts (thin handler)
        src/main/services/account.service.ts (business logic)

Step 1: Create service file with extracted logic
Step 2: Import service in IPC handler
Step 3: Replace inline logic with service calls (one handler at a time)
Step 4: Verify each handler still works
Step 5: Run npm run typecheck
```

### Recipe 8: Move Code Between mkt-core and Project

When promoting project code to shared core or pulling core code into project:

```
Step 1: Copy code to target location (don't move yet)
Step 2: Update imports in target location
Step 3: Test that target location works independently
Step 4: Migrate callers from old to new location (one at a time)
Step 5: Remove from old location
Step 6: Update submodule reference (if moving to core)
Step 7: Verify both main and renderer mkt-core work
```

**Key rule**: Never modify mkt-core submodule without updating both branches (main + renderer-v2).

---

## Library-Specific Recipes

### Recipe 9: Add New Provider Type

When adding a new provider variant:

> Provider structure: see `.claude/rules/provider-pattern.md`

Then add test case to `test/provider.test.ts` and run: `yarn test && yarn build`

### Recipe 10: Refactor Provider Action Structure

When splitting or reorganizing actions within a provider:

```
Before: One large action class doing everything
After:  Multiple focused action classes

Step 1: Identify responsibility groups in the existing action
Step 2: Create new action classes (extend LabsBaseClass)
Step 3: Export from actions/index.ts
Step 4: Instantiate in provider.ts constructor
Step 5: Update provider start() to orchestrate new actions
Step 6: Update logUpdate keys for new action names
Step 7: Run: yarn test
```

### Recipe 11: Change Provider Interface Contract

**High risk** — affects all consumers:

```
Step 1: Create ADR documenting why the change is needed
Step 2: Add new methods to interface (don't remove old ones yet)
Step 3: Implement new methods in all providers
Step 4: Update tests for new methods
Step 5: Migrate consumers to new methods (one project at a time)
Step 6: Deprecate old methods (mark with @deprecated)
Step 7: Remove old methods in next major version
Step 8: Bump version: major if breaking, minor if additive
```

---

## Impact Analysis (Before Refactoring)

### 3-Step Process

**1. Discovery** — Find all references:

```
# Find all usages of the target (use Grep tool)
Grep: TargetClass|TargetFunction (across src/)

# Find all importers
Grep: import.*from.*target-module (across src/)

# For Electron: check all 3 processes
Grep: <target> in src/main/, src/preload/, src/renderer/
```

**2. Understanding** — For each reference:

- What is the caller's purpose?
- What is the dependency direction?
- What data flows through this reference?
- **Electron**: Which process is this in? (main/preload/renderer)
- **Library**: Is this a public or internal API?

**3. Impact Report**:

```markdown
## Direct Impact

- FileA.ts: Uses TargetFunction for X
- FileB.ts: Extends TargetClass for Y

## Indirect Impact

- ModuleC depends on FileA's output
- IPC channel X depends on this (Electron)
- Consumer project Y uses this interface (Library)

## Cross-Process Impact (Electron)

| Process  | Files Affected | Risk                |
| -------- | -------------- | ------------------- |
| Main     | 2              | Low                 |
| Preload  | 1              | Low (mirror update) |
| Renderer | 3              | Medium              |

## Risk

- Low: Internal refactor, no public API change
```

## Verification Commands

| Project Type | Commands                                                        |
| ------------ | --------------------------------------------------------------- |
| Electron     | `npm run flint && npm run typecheck`                            |
| Library      | `npm run flint && npm run typecheck && yarn test`               |
| Any (full)   | `npm run flint && npm run typecheck && yarn test && yarn build` |

## Anti-Patterns in Refactoring

| Anti-Pattern                    | Problem                       | Correct Approach                              |
| ------------------------------- | ----------------------------- | --------------------------------------------- |
| Refactoring without safety net  | No verification               | Use typecheck as minimum safety net           |
| Big bang rewrite                | High risk, long feedback loop | Incremental migration                         |
| Refactoring during feature work | Mixed concerns in PR          | Separate refactoring PRs                      |
| Premature optimization          | No data to support            | Profile first, optimize second                |
| Gold plating                    | Over-engineering              | Refactor to what's needed now                 |
| Ignoring downstream impact      | Breaks consumers              | Impact analysis before starting               |
| Changing IPC without preload    | Breaks renderer               | Always update main + preload + types together |
| Modifying mkt-core one branch   | Breaks other process          | Update both main and renderer-v2 branches     |
| Removing provider method        | Breaks consumers              | Deprecate first, remove in major version      |
