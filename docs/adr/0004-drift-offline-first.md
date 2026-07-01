# ADR-0004 — Drift para persistencia offline-first

- **Estado:** Aceptado
- **Fecha:** 2026-07-01

## Contexto
La app debe funcionar offline y dar soporte web. Necesitamos una caché local de listados y
detalles que: (a) funcione en móvil **y** en web, (b) permita el patrón single-source-of-
truth con actualizaciones reactivas, y (c) sea type-safe y testeable.

Alternativas consideradas:
- **Hive CE**: key-value simple, rápido de montar. Menos consultas estructuradas, sin
  relaciones ni queries reactivas ricas.
- **Isar**: rápido, pero soporte web débil y mantenimiento incierto. Descartado por el
  requisito web.
- **sqflite**: sin soporte web nativo. Descartado.

## Decisión
Usamos **Drift** (SQLite type-safe).

- Funciona en web mediante `sqlite3` compilado a **WASM** (worker + wasm asset).
- Ofrece **queries reactivas** (`watch`) que encajan con RN-5: el repositorio emite desde
  la tabla local y la red actualiza la caché en segundo plano.
- Consultas y esquema type-safe verificados en tiempo de compilación.

## Consecuencias
- (+) Una sola solución de persistencia para todas las plataformas, incluida web.
- (+) Reactividad nativa → offline-first limpio sin polling.
- (+) Migraciones y esquema versionados.
- (−) Setup de assets WASM para web y de `build_runner`. Coste único, documentado en el
  README.
- (−) Más pesado que un key-value para datos triviales; se justifica por reactividad + web.
