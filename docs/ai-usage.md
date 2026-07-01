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

### 2026-07-01 — M0: andamiaje del monorepo

- **Qué se pidió a la IA:** montar el workspace Melos con los 4 paquetes, cablear el
  linter VGV, construir los services base de `core` y los tokens/tema de `design_system`,
  y dejar CI + hooks locales.
- **Aporte de la IA:**
  - Scaffolding del monorepo (pub workspaces + Melos 7 con config en `pubspec.yaml`);
    resolución de dependencias vía `pub add` para no fijar versiones a mano.
  - `core`: `AppConfig` (token vía `--dart-define-from-file`), jerarquía `Failure` +
    `Either` (fpdart), `ApiClient` sobre Dio, logging con **Talker**, DI con Riverpod
    (code-gen).
  - `design_system`: paleta MARQUEE (dark/light) como `ThemeExtension`, tema claro/oscuro,
    componentes `PosterCard`/`ShimmerBox`.
- **Decisiones humanas:**
  - Scope maximalista (web/Drift dentro, películas + series, Melos 4 paquetes).
  - **Fuentes (Sora, IBM Plex Sans) empaquetadas como assets** en vez de `google_fonts`,
    coherente con offline-first.
  - **Talker** como backbone de logging; **commits sin co-autoría de IA**.
  - Desactivar `public_member_api_docs` de VGV: paquetes internos + estilo Clean Code sin
    comentarios redundantes.
- **Verificación:** `melos run analyze` + `generate` + `test` en verde; 3 paquetes con
  tests unitarios/widget.

### 2026-07-01 — M1: Catálogo (HU-1) end-to-end, dominio-primero

- **Qué se pidió a la IA:** implementar la pantalla de catálogo con datos reales de
  TMDB, paginación y estados de UI, empezando por el dominio.
- **Aporte de la IA:**
  - Modeló el dominio a partir del **JSON real** de TMDB (diferencias movie/tv), diseñó
    el contrato de repositorio **reactivo**, la capa de datos (DTOs freezed, datasource,
    mapper, repo con caché reactiva en memoria) y la presentación (notifier con
    paginación; Catalog Home con toggle y carruseles Popular/Top Rated; estados
    skeleton/error/data).
  - Analizó los mockups de Claude Design (pantallas + States) para guiar la fidelidad.
- **Decisiones humanas / de diseño:**
  - **Sin usecases pass-through**: el notifier usa el contrato del repositorio; añadir
    usecases que solo reenvían sería la capa ceremonial que el ADR-0001 dice evitar.
  - Hero "Featured Tonight" diferido al pulido (M6).
  - Offline: pantalla completa sin caché / banner ligero con caché (a implementar en M4).
- **Verificación:** 12 tests en `feature_catalog` (dominio, mapper, repo con acumulación
  de páginas y offline-first) + widget test del app; `melos analyze`/`test` verdes; el
  build web compila el grafo completo con el token real.

<!-- Próximas entradas se añaden aquí a medida que avanzamos. -->
