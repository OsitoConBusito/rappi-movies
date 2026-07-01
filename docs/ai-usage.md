# Uso de IA en el proyecto

El enunciado permite el uso de IA y pide aclarar **cómo** se usó. Este documento es la
bitácora honesta de esa colaboración.

## Herramienta
- **Claude (Anthropic)** vía Claude Code, como par de programación.

## Filosofía
La IA se usó para **acelerar**, no para reemplazar criterio. Todas las decisiones
arquitectónicas fueron revisadas y aprobadas explícitamente por el autor. Ningún ADR se
aceptó sin discusión.

## Bitácora

### 2026-07-01 — Encuadre y decisiones iniciales
- **Qué se pidió a la IA:** evaluar el plan de alto nivel (clean architecture, offline,
  responsive, web, testing completo, modularización) frente al presupuesto de tiempo del
  ejercicio (6–9 h) y recomendar librerías.
- **Aporte de la IA:**
  - Señaló el riesgo alcance vs. tiempo y propuso estrategia *vertical slice first*.
  - Recomendó **Drift** para offline con soporte web (frente a Isar/Hive), **go_router**
    sobre fluro para deep-linking web, y el matiz de conectividad real
    (`connectivity_plus` + `internet_connection_checker_plus`).
  - Propuso dominio genérico `Media`/`MediaType` para unificar pelis y series sin duplicar
    UI/tests.
- **Decisión humana:** se aceptaron Drift, go_router, cobertura pelis+series, y estructura
  modular de 4 paquetes. Se generó el spec y los ADRs 0001–0007.
- **Verificación:** pendiente de implementación; cada decisión quedará validada por tests.

<!-- Próximas entradas se añaden aquí a medida que avanzamos. -->
