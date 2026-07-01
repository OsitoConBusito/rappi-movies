# Architecture Decision Records (ADR)

Registro de decisiones arquitectónicas del proyecto. Cada ADR captura el **contexto**, la
**decisión** y sus **consecuencias**, para que cualquiera entienda *por qué* algo es como
es sin arqueología de git.

Formato basado en [Michael Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions).

| #    | Título                                             | Estado    |
|------|----------------------------------------------------|-----------|
| 0001 | Clean Architecture por capas                       | Aceptado  |
| 0002 | Monorepo modular con Melos                          | Aceptado  |
| 0003 | Riverpod como state management                     | Aceptado  |
| 0004 | Drift para persistencia offline-first              | Aceptado  |
| 0005 | go_router en lugar de fluro                        | Aceptado  |
| 0006 | Result (fpdart) para manejo de errores             | Aceptado  |
| 0007 | Estrategia de detección de conectividad            | Aceptado  |

## Estados posibles
`Propuesto` → `Aceptado` → (`Deprecado` | `Reemplazado por ADR-XXXX`)
