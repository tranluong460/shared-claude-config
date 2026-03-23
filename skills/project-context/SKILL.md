---
name: project-context
description: Project-specific context, tech stack, architecture decisions, and build/test commands. Fill in for your project.
layer: project
---

# Project Context

> **TEMPLATE** — Fill in the sections below with your project's specific details.
> Agents and commands reference this skill for project-specific decisions.

## Project Identity

| Field | Value |
|-------|-------|
| Name | <!-- project name --> |
| Type | <!-- Electron App / Module Library / Node.js Server --> |
| Description | <!-- one-line purpose --> |

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Runtime | <!-- Node.js X.x / Electron X.x --> |
| Language | <!-- TypeScript X.x --> |
| Database | <!-- TypeORM + SQLite / Prisma + PostgreSQL / none --> |
| UI Framework | <!-- React / Vue / none --> |
| Build Tool | <!-- electron-vite / Vite / tsc --> |
| Test Framework | <!-- vitest / jest / none --> |

## Build & Test Commands

| Action | Command |
|--------|---------|
| Install | <!-- yarn install --> |
| Dev | <!-- npm run dev --> |
| Build | <!-- npm run build --> |
| Lint + Format | <!-- npm run flint --> |
| Typecheck | <!-- npm run typecheck --> |
| Test | <!-- yarn test --> |

## Architecture Decisions

<!-- List key architectural decisions specific to this project -->

1. **Decision**: <!-- description --> — **Reason**: <!-- why -->

## Business Rules & Constraints

<!-- List project-specific rules that AI should always follow -->

- <!-- rule 1 -->

## Known Gotchas

<!-- Things that are easy to get wrong in this codebase -->

- <!-- gotcha 1 -->
