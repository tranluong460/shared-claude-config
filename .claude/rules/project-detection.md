# Project Type Detection (always active)

> Auto-detect project type before applying analysis. This is the canonical detection table — do not duplicate in commands or agents.

| Type               | Indicators                                                       |
| ------------------ | ---------------------------------------------------------------- |
| **Electron App**   | `electron` in deps, `src/main/`, `src/preload/`, `src/renderer/` |
| **Module Library** | `src/providers/`, `src/core/` with Factory/Registry/Facade       |
| **Node.js Server** | `express`/`fastify`/`nestjs` in deps                             |

## How to detect

```
Read package.json → check dependencies and src/ structure
```
