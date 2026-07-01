# ADR-0002 — Monorepo modular con Melos

- **Estado:** Aceptado
- **Fecha:** 2026-07-01

## Contexto
Queremos demostrar modularización real y límites de dependencia explícitos, sin caer en
over-engineering (KISS/YAGNI) para una app de este tamaño. Un único paquete monolítico
oculta acoplamientos; 15 micro-paquetes serían ceremonia inútil.

## Decisión
Monorepo gestionado con **Melos 7.x**, con **4 paquetes** de responsabilidad clara:

| Paquete          | Responsabilidad                                                    |
|------------------|--------------------------------------------------------------------|
| `app`            | Entrypoint, composición de DI, router, shell responsive.           |
| `design_system`  | Tema claro/oscuro, tokens, componentes, animaciones base.          |
| `core`           | Networking (Dio), `Result`, conectividad, errores, storage (Drift).|
| `catalog`        | Feature: `domain` / `data` / `presentation` de pelis y series.     |

Reglas de dependencia entre paquetes:
`app → {catalog, design_system, core}`, `catalog → {core, design_system}`,
`design_system → ∅`, `core → ∅`. Nada apunta hacia `app`.

Melos centraliza scripts: `analyze`, `test`, `format`, `generate` (build_runner),
`golden`.

## Consecuencias
- (+) Fronteras de dependencia explícitas y verificables.
- (+) `core` y `design_system` reutilizables en hipotéticas features futuras.
- (+) Scripts unificados y CI sencilla.
- (−) Setup inicial de Melos + `pubspec` por paquete. Coste único y acotado.
- (−) Si el proyecto no creciera, 4 paquetes podrían parecer muchos; se juzga justificado
  por ser una demostración explícita de capacidad de modularización.
