---
name: architecture-patterns
description: Project structure reference for Electron apps, Node.js projects, and module-based libraries. Process rules enforced via .claude/rules/ — this skill provides structure diagrams and pattern examples.
layer: architecture
---

# Architecture Patterns — Reference

> Process rules (IPC sync, process isolation, provider pattern) are enforced via `.claude/rules/electron.md`, `rules/ipc.md`, `rules/provider-pattern.md`. This skill provides structure reference and pattern examples.

## 1. Electron App Structure

```
src/
├── main/                         # Main process (Node.js)
│   ├── index.ts                  # App lifecycle
│   ├── ipc/                      # IPC handlers (1 file per domain)
│   ├── database/                 # TypeORM + better-sqlite3
│   │   ├── entities/             # @Entity classes
│   │   └── models/               # CRUD model objects
│   ├── helper/                   # App helpers (window, job, settings, export)
│   ├── nodejs/                   # Workers, file ops, constants
│   └── types/
├── preload/                      # Context bridge (mirrors main/ipc/)
│   ├── ipc/                      # Proxies using ipcRendererInvoke
│   └── types/                    # ArgRoutes definitions
└── renderer/src/                 # React + Vite
    ├── components/               # common/ + ui/
    ├── pages/                    # Page components
    ├── layouts/                  # Layout wrappers
    ├── hooks/                    # Custom React hooks
    ├── services/                 # API endpoints + React Query hooks
    ├── routes/                   # Route config
    └── assets/                   # CSS, images, locales
```

### IPC Data Flow

```
Page → useQuery/useMutation hook
  → {Domain}Api (window.api.{domain}.{method})
    → Preload (ipcRendererInvoke)
      → Main (ipcMainHandle)
        → Model / Service / DB
      → return IMainResponse<T>
    → return to renderer
  → React Query updates state
```

## 2. Module-Based Library (base-factory)

```
src/
├── index.ts                    # Public API
├── core/                       # PluginLoader, Registry, Facade
├── interfaces/providers/       # Factory interface, types
├── providers/
│   ├── shared/base.ts          # LabsBaseClass
│   ├── automated/              # factory.ts, provider.ts, services/actions/
│   ├── scripted/
│   └── direct-api/
├── utils/                      # Public + private/http/
└── locales/
```

### Provider Flow

```
Consumer → LabsProviderFacade.getProvider(payload)
  → LabsPluginLoader.loadPlugin(type)
    → import(`providers/${type}/index.ts`)
    → plugin.register() → LabsProviderRegistry.register()
  → Registry.getFactory(type).create(payload)
  → provider.start() → action.start() → this.logUpdate()
```

## 3. Dependency Direction

```
Electron:  Renderer → Preload → Main → DB/Workers
Library:   Consumer → Facade → Registry → Factory → Provider → Actions
General:   Controllers → Services → Repositories → Database
```

## Common Patterns

### Repository Pattern

Abstracts data access behind interface — implementation swappable.

### Service Layer

Business logic isolated from transport (IPC/HTTP).

### Factory + Registry

Dynamic provider selection at runtime — `register()` + `getFactory()` + `create()`.

### Event-Driven

Decouple modules: `eventBus.emit()` / `eventBus.on()`.

## Architecture Smells

| Smell                   | Solution                 |
| ----------------------- | ------------------------ |
| God module (300+ lines) | Split by responsibility  |
| Spaghetti imports (10+) | Review module boundaries |
| Shared mutable state    | DI, events, immutable    |
| Leaky abstraction       | Repository pattern       |
| Bypassed preload        | contextBridge + proxy    |
| Missing barrel export   | Add `index.ts`           |
