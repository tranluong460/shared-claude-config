---
name: impact-analysis
description: Techniques for analyzing blast radius, dependency graphs, and protecting business logic when modifying code. Covers static analysis, test coverage mapping, co-change detection, and safe change strategies.
layer: architecture
---

# Impact Analysis & Business Logic Protection

## Core Principle

> Mọi thay đổi code đều có **blast radius** — tập hợp các function, module, và business flow bị ảnh hưởng.
> Trước khi sửa, phải biết blast radius. Sau khi sửa, phải verify toàn bộ blast radius.

## Khi Nào Cần Impact Analysis

| Trigger                                         | Mức độ khẩn cấp                             |
| ----------------------------------------------- | ------------------------------------------- |
| Sửa function được nhiều module gọi (≥3 callers) | **Critical** — bắt buộc phân tích           |
| Thay đổi DB schema (thêm/sửa/xóa column)        | **Critical** — ảnh hưởng toàn bộ data layer |
| Sửa shared utility/helper function              | **High** — có thể ảnh hưởng rộng            |
| Thay đổi interface/type definition              | **High** — ảnh hưởng tất cả implementors    |
| Sửa API contract (request/response shape)       | **High** — ảnh hưởng client lẫn server      |
| Refactor module nội bộ (1-2 files)              | **Medium** — cần kiểm tra callers           |
| Thay đổi UI component đơn lẻ                    | **Low** — blast radius hạn chế              |

## Phân Tích Dependency Graph

### Level 1: Direct Dependencies (Callers & Callees)

```
# Tìm ai gọi function/class mục tiêu
Grep: TargetFunction|TargetClass (across src/)

# Tìm ai import module mục tiêu
Grep: import.*from.*target-module (across src/)

# Tìm ai extend/implement interface mục tiêu
Grep: extends TargetClass|implements ITarget (across src/)
```

### Level 2: Transitive Dependencies (2-hop)

Với mỗi caller tìm được ở Level 1, lặp lại:

```
# Ai gọi caller?
Grep: CallerFunction|CallerClass (across src/)
```

Tạo dependency chain: `Caller → Target → Callee`

### Level 3: Cross-Boundary Dependencies

| Boundary                     | Cách kiểm tra                                      |
| ---------------------------- | -------------------------------------------------- |
| Process boundary (Electron)  | Kiểm tra main/ → preload/ → renderer/              |
| Package boundary (Monorepo)  | Kiểm tra cross-package imports                     |
| API boundary (Client-Server) | Kiểm tra API contract consumers                    |
| DB boundary                  | Kiểm tra tất cả queries/entities dùng table/column |

## Business Logic Classification

### Xác định Critical Paths

Business logic được phân loại theo mức độ critical:

| Tier       | Loại           | Ví dụ                               | Quy tắc                                                   |
| ---------- | -------------- | ----------------------------------- | --------------------------------------------------------- |
| **Tier 1** | Core Revenue   | Payment, billing, subscription      | Zero tolerance — phải có 100% test coverage trước khi sửa |
| **Tier 2** | Core Function  | Auth, permissions, data integrity   | Near-zero tolerance — cần approval + comprehensive tests  |
| **Tier 3** | Business Rules | Validation, workflow, notifications | Careful — cần impact analysis + regression tests          |
| **Tier 4** | Supporting     | Logging, formatting, UI helpers     | Standard — basic testing đủ                               |

### Phát Hiện Business Logic

```
# Tìm business rules trong code
Grep: validate|calculate|process|authorize|verify|check[A-Z] (across src/)

# Tìm guard clauses và business constraints
Grep: throw.*Error|throw.*Exception|reject\( (across src/)

# Tìm financial/payment logic
Grep: price|amount|total|discount|tax|payment|billing|charge (across src/)

# Tìm permission/auth logic
Grep: permission|role|access|authorize|canUser|isAllowed (across src/)
```

## Test Coverage Mapping

### Xác Định Safety Net

Trước khi sửa bất kỳ code nào, phải biết:

1. **Test nào cover function mục tiêu?**

```
# Tìm test files import module mục tiêu
Grep: import.*from.*target-module (across test/, __tests__/, *.test.ts, *.spec.ts)

# Tìm test cases gọi function mục tiêu
Grep: TargetFunction|TargetClass (across test/, __tests__/)
```

2. **Coverage gaps** — function không có test nào cover = highest risk

3. **Test quality** — test chỉ check happy path ≠ đầy đủ coverage

### Coverage Decision Matrix

| Test Coverage | Business Tier | Action                                      |
| ------------- | ------------- | ------------------------------------------- |
| High (>80%)   | Tier 1-2      | ✅ Proceed with caution                     |
| High (>80%)   | Tier 3-4      | ✅ Safe to proceed                          |
| Low (<50%)    | Tier 1-2      | 🛑 STOP — Viết tests trước, sửa code sau    |
| Low (<50%)    | Tier 3-4      | ⚠️ Viết characterization tests trước        |
| None (0%)     | Any           | 🛑 STOP — Viết characterization tests trước |

## Git Co-Change Analysis

Phân tích git history để tìm files thường thay đổi cùng nhau:

```bash
# Tìm files thường commit cùng target file
git log --follow --format="%H" -- <target-file> | head -20 | \
  xargs -I{} git diff-tree --no-commit-id --name-only -r {} | \
  sort | uniq -c | sort -rn | head -20

# Tìm recent changes liên quan
git log --oneline --all -20 -- <target-file>
```

Files có co-change frequency cao = likely dependent, dù không có static import.

## Safe Change Strategies

### Strategy 1: Expand-Contract Pattern

Khi sửa function có nhiều callers:

```
Phase 1: EXPAND — Thêm function mới bên cạnh function cũ
  - Tạo newFunction() với logic mới
  - Function cũ vẫn hoạt động bình thường
  - Tests: verify newFunction() works

Phase 2: MIGRATE — Chuyển callers sang function mới
  - Chuyển từng caller một (không batch)
  - Test sau mỗi caller migration
  - Function cũ dần không còn ai gọi

Phase 3: CONTRACT — Xóa function cũ
  - Verify không còn caller nào
  - Xóa function cũ
  - Final test run
```

### Strategy 2: Feature Flag Protection

Khi thay đổi business logic có risk cao:

```
Phase 1: Wrap logic mới trong feature flag
  - if (featureEnabled('new-logic')) { newLogic() } else { oldLogic() }
  - Deploy với flag OFF

Phase 2: Gradual rollout
  - Enable cho internal users trước
  - Monitor for errors/anomalies
  - Enable cho tất cả users

Phase 3: Cleanup
  - Remove feature flag
  - Remove old logic
```

### Strategy 3: Parallel Run

Khi sửa critical business logic (Tier 1-2):

```
Phase 1: Run cả old và new logic song song
  - oldResult = oldFunction(input)
  - newResult = newFunction(input)
  - Log differences: if (oldResult !== newResult) logDiscrepancy()
  - Return oldResult (safe)

Phase 2: Khi 0 discrepancies sau N iterations
  - Switch to return newResult
  - Vẫn chạy oldFunction để so sánh

Phase 3: Remove old logic
```

### Strategy 4: DB Schema Change Safety

Khi thay đổi database schema:

```
Phase 1: ADD (non-breaking)
  - Thêm columns mới (nullable, có default)
  - KHÔNG xóa hay rename columns cũ
  - Deploy code đọc được cả old và new columns

Phase 2: MIGRATE data
  - Script migration từ old → new columns
  - Verify data integrity

Phase 3: SWITCH code
  - Update code để dùng new columns
  - Old columns vẫn tồn tại nhưng không được sử dụng

Phase 4: CLEANUP (sau khi stable)
  - Remove old columns
  - Chỉ khi confirmed không có process nào đọc old columns
```

## Impact Report Template

```markdown
## Impact Analysis Report

### Target Change

- **What**: <mô tả thay đổi>
- **File(s)**: <file paths>
- **Function(s)**: <function names>

### Business Logic Tier: <Tier 1/2/3/4>

### Blast Radius

#### Direct Impact (Level 1)

| File       | Function  | Dependency Type | Risk   |
| ---------- | --------- | --------------- | ------ |
| file.ts:42 | callerA() | calls target    | Medium |

#### Transitive Impact (Level 2)

| File        | Function   | Through       | Risk |
| ----------- | ---------- | ------------- | ---- |
| other.ts:15 | userFlow() | via callerA() | Low  |

#### Cross-Boundary Impact

| Boundary | Affected | Details                   |
| -------- | -------- | ------------------------- |
| DB       | Yes/No   | <tables/columns affected> |
| API      | Yes/No   | <endpoints affected>      |
| Process  | Yes/No   | <main/preload/renderer>   |

### Test Coverage

- **Covered functions**: X/Y (Z%)
- **Uncovered functions**: <list>
- **Missing test scenarios**: <list>

### Risk Assessment

| Factor               | Level                     | Details              |
| -------------------- | ------------------------- | -------------------- |
| Blast radius         | Low/Med/High              | N files, M functions |
| Test coverage        | Low/Med/High              | Z% coverage          |
| Business criticality | Tier 1-4                  | <reasoning>          |
| Rollback complexity  | Low/Med/High              | <reasoning>          |
| **Overall Risk**     | **Low/Med/High/Critical** |                      |

### Recommended Strategy

- **Approach**: <Expand-Contract / Feature Flag / Parallel Run / Direct>
- **Pre-conditions**: <tests to write first>
- **Verification**: <commands to run>

### Action Items

1. [ ] <specific action>
2. [ ] <specific action>
```

## Anti-Patterns

| Anti-Pattern                                          | Hậu quả                   | Cách đúng                               |
| ----------------------------------------------------- | ------------------------- | --------------------------------------- |
| Sửa function mà không biết ai gọi nó                  | Break callers             | Luôn tìm all callers trước              |
| Sửa DB schema trực tiếp                               | Data loss, downtime       | Dùng expand-contract cho schema         |
| Sửa shared type/interface mà không check implementors | Compile errors everywhere | Grep tất cả implementors trước          |
| Xóa function "không ai dùng" mà không verify          | Runtime errors            | Grep toàn project + check dynamic calls |
| Sửa business logic không có tests                     | Silent bugs               | Viết characterization tests trước       |
| Batch sửa nhiều callers cùng lúc                      | Khó debug khi fail        | Sửa từng caller, test sau mỗi cái       |
| Refactor + thay đổi behavior cùng lúc                 | Impossible to verify      | Tách thành 2 commits riêng biệt         |
