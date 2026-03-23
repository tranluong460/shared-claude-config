---
name: naming-conventions
description: Naming reference with examples for Node.js / TypeScript / Electron projects. Core rules enforced via .claude/rules/code-quality.md — this skill provides detailed examples and patterns.
layer: core
---

# Naming Conventions — Reference & Examples

> Core enforcement rules are in `.claude/rules/code-quality.md`. This skill provides detailed examples and the A/HC/LC pattern reference.

## Core Principles

- **S-I-D**: Short, Intuitive, Descriptive
- **No contractions**: `getUserName` not `getUsrNme`
- **No context duplication**: `userService.getSettings()` not `userService.getUserSettings()`
- **Reflect expected result**: `isDisabled` not `!isEnabled`
- **English only**

## Case Conventions

| Element            | Convention            | Example                      |
| ------------------ | --------------------- | ---------------------------- |
| Folders            | `kebab-case`          | `browser-window/`            |
| Files (services)   | `{entity}.service.ts` | `message-handler.service.ts` |
| Files (entities)   | `{Entity}Entity.ts`   | `AccountEntity.ts`           |
| Files (components) | `PascalCase.tsx`      | `ButtonActionControl.tsx`    |
| Enums              | `E` + PascalCase      | `EPlatform`                  |
| Interfaces/Types   | `I` + PascalCase      | `IUserService`               |
| React Props        | `{Component}Props`    | `ButtonActionControlProps`   |
| IPC channels       | `{domain}_{action}`   | `account_create`             |
| DB fields          | `snake_case`          | `is_auto`                    |

## A/HC/LC Function Pattern

```
prefix? + action (A) + high context (HC) + low context? (LC)
```

| Name                   | Prefix   | Action    | HC        | LC         |
| ---------------------- | -------- | --------- | --------- | ---------- |
| `getUser`              |          | `get`     | `User`    |            |
| `getUserMessages`      |          | `get`     | `User`    | `Messages` |
| `shouldDisplayMessage` | `should` | `Display` | `Message` |            |

## Action Verbs

| Action                           | Meaning                      | Example                          |
| -------------------------------- | ---------------------------- | -------------------------------- |
| `get`                            | Sync internal getter         | `getUserFullName()`              |
| `fetch`                          | Async API/DB request         | `fetchUsers()`                   |
| `find`                           | Search/query                 | `findActiveUsers()`              |
| `create`                         | New entity                   | `createUser()`                   |
| `build`                          | Step-by-step construction    | `buildQuery()`                   |
| `update`                         | Modify existing              | `updateEmail()`                  |
| `remove`                         | From collection (reversible) | `removeFilter()`                 |
| `delete`                         | Permanent (DB)               | `deleteUser()`                   |
| `set` / `reset`                  | Assign / restore initial     | `setStatus()` / `resetFilters()` |
| `validate` / `check`             | Verify correctness           | `validateEmail()`                |
| `transform` / `parse` / `format` | Convert data                 | `parseDate()`                    |

## Class Role Suffixes

| Role     | Suffix     | Example                  |
| -------- | ---------- | ------------------------ |
| Service  | `Service`  | `BrowserLauncherService` |
| Manager  | `Manager`  | `WindowManager`          |
| Factory  | `Factory`  | `AutomatedFactory`       |
| Provider | `Provider` | `ScriptedProvider`       |
| Registry | `Registry` | `LabsProviderRegistry`   |
| Error    | `Error`    | `ValidationError`        |

## Type/Interface Suffixes

| Purpose | Suffix    | Example                    |
| ------- | --------- | -------------------------- |
| Input   | `Input`   | `ICreateUserInput`         |
| Result  | `Result`  | `ICreateUserResult`        |
| Options | `Options` | `IRetryOptions`            |
| Payload | `Payload` | `IResponsePayload<T>`      |
| Props   | `Props`   | `ButtonActionControlProps` |

## Function Name Smells

| Smell                 | Fix                           |
| --------------------- | ----------------------------- |
| `processData()`       | `transformUserResponse()`     |
| `handleStuff()`       | `handlePaymentWebhook()`      |
| `doWork()`            | `syncInventoryWithSupplier()` |
| `utils.ts` 500+ lines | Split into focused modules    |
