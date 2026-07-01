# Plan de Ejecución

- **Estado:** Aprobado
- **Última actualización:** 2026-07-01
- **Fuente:** enunciado del ejercicio + [spec de catálogo](../.specs/features/catalog.md) + [ADRs](adr/README.md)

Este documento traduce el spec y los ADRs en una secuencia de trabajo verificable. El
principio es **vertical slice first** con una **línea demo-segura**: en cada milestone hay
una entrega parcial defendible, de modo que si algo se atasca (candidato #1: WASM en web),
se degrada ese punto a "documentado en README" sin quedarse sin app.

## Principios rectores

- **Clean Architecture feature-first** (ADR-0001, ADR-0002). Dentro de cada feature:
  `domain` → `data` → `presentation`. Ver árbol en ADR-0002.
- **Dominio primero**, informado por el contrato real de la API. El contrato del
  repositorio se diseña **reactivo** (`Stream<Either<Failure, T>>`) desde el día 1, con
  impl remote-only primero y Drift (single-source-of-truth) como *drop-in* después. Así el
  refactor a offline-first en M4 queda localizado en la impl del repo, sin tocar dominio ni
  UI.
- **Definition of Done incluye documentación** (ver más abajo).

## Capa `core`: services como abstracciones

Cada service es **interfaz + impl + provider Riverpod** (DI, ADR-0003). Las features
dependen del contrato, no de Dio/Drift.

| Service             | Responsabilidad                                                 | Backing                                |
|---------------------|-----------------------------------------------------------------|----------------------------------------|
| `ApiClient`         | GET tipado, base URL, interceptor auth Bearer, error→`Failure`  | Dio (+ `talker_dio_logger`)            |
| `AppDatabase`       | caché reactiva (`watch`), DAOs por tabla                        | Drift (móvil + WASM web)               |
| `KeyValueStore`     | prefs ligeras (theme mode, locale)                              | shared_preferences                     |
| `ConnectivityService` | `Stream<ConnectionStatus>` de internet real (ADR-0007)        | connectivity_plus + reachability       |
| `AppLogger`         | logging estructurado (nada de `print`); UI de logs en debug     | **Talker** (`talker_flutter`, `talker_dio_logger`, `talker_riverpod_logger`) |
| `AppConfig`         | token + base URLs + image config vía `--dart-define-from-file`  | —                                      |

`Talker` es el backbone de observabilidad: una sola instancia inyectada como interceptor de
Dio (logs de red), observer de Riverpod (cambios de estado) y logger de la app.

## Milestones

Cada milestone lista su Definition of Done (DoD) y cómo se verifica.

### M0 · Andamiaje · ~1.5 h
- Melos + 4 paquetes (`app`/`core`/`design_system`/`features/feature_catalog`) con reglas
  de dependencia.
- Linter **VGV** (`very_good_analysis`) en raíz + override por paquete.
- `core`: `ApiClient` (Dio + interceptor Bearer), jerarquía `Failure`, `Either`, `AppConfig`.
- `design_system`: tokens MARQUEE (colores dark/light `--bg/--s1..s3/--tx../--accent`,
  tipografía Sora + IBM Plex, grid 4pt, radios, 4 elevaciones) como `ColorScheme` + theme
  extensions; `PosterCard` + shimmer.
- CI (GitHub Actions): `analyze` + `test` + `format`.
- Guardrail: hooks `record-dart-edit` + `analyze-on-stop` (traídos de espectaculapp).
- **DoD/verify:** CI verde con test trivial; app arranca.

### M1 · Slice vertical HU-1 (Popular movies, remote-only) · ~1.5 h → 🟢 demo-segura #1
- `domain`: `Media`/`MediaType`/`MediaCategory`, interfaz de repo reactiva, usecase.
- `data`: DTO (freezed), remote datasource (Dio), mapper, repo impl remote-only.
- `presentation`: `AsyncNotifier`, grid, estados loading(shimmer)/data/error(retry)/empty
  + paginación.
- **Tests:** mapper, repo (fake datasource), notifier (`ProviderContainer` + overrides).
- **DoD:** Popular movies real de TMDB con scroll infinito; tests verdes.

### M2 · Ensanchar dominio: tv + top_rated · ~0.75 h
- Reusar `Media`; 4 listados (movie/tv × popular/top_rated). Tests parametrizados.

### M3 · Detalle HU-2 + animaciones · ~1.25 h
- `MediaDetail` (géneros, runtime, reparto); endpoint de detalle.
- **Hero** poster list→detail + `SliverAppBar` colapsable con backdrop + fade/stagger al
  scroll (el guiño explícito del enunciado).
- **DoD:** transición pulida y detalle completo; tests del notifier.

### M4 · Offline-first real (Drift + WASM web) · ~1.5–2.5 h
- Drift DB/tablas/DAOs en `core`. Repo pasa a **SSOT**: emite desde `watch`, red refresca
  en background (swap detrás de la interfaz existente).
- WASM assets (sqlite3 wasm + worker) para web. `ConnectivityService` + banner offline.
- **DoD:** modo avión móvil sigue mostrando cacheado; corre en Chrome con persistencia.
- **Checkpoint de riesgo:** si WASM se atasca, offline móvil ya funciona → web a
  "documentado en README".

### M5 · Búsqueda HU-3 · ~1 h
- Endpoint search, debounce, filtro por tipo, empty/offline states + tests.

### M6 · Responsive + pulido + cierre · ~1.5 h
- Layouts phone/tablet(/desktop web), dark mode, accesibilidad (semántica, targets ≥48dp).
- README completo: setup, token (`--dart-define-from-file`), arquitectura, link a ADRs,
  "cómo lo haría" (auth TMDB, tráilers, push), bitácora IA. 1–2 golden opcionales. CI verde.

## Definition of Done (por milestone)

1. Código con tests verdes de las capas tocadas.
2. `melos analyze` + `melos format` limpios.
3. **Documentación actualizada**: fecha "Reconciliado contra código" del spec, ADR afectado
   si hubo decisión nueva, y entrada en la bitácora [`docs/ai-usage.md`](ai-usage.md).
4. Commit atómico convencional (sin trailer de co-autoría de IA).

## Tooling reutilizado de espectaculapp

- **Traído:** hooks `record-dart-edit.sh` + `analyze-on-stop.sh` (analyze en paquetes
  tocados al cerrar sesión); agente `barrel-cop` (vigila API pública de barrels).
- **Opcional:** `check-commit-subject.sh` (si se adopta commitlint).
- **Descartado (YAGNI para 1 feature / 6–9 h):** `feature-scaffolder`, `test-generator`,
  cops de DS/i18n/tokens (acoplados al DS y librerías de espectaculapp), comandos de sesión
  y todo el toolchain BE.

## Notas de entorno

- Flutter 3.44.2 stable / Dart 3.12.2 (bundle) / Melos 7.4.0.
- El enunciado cita "Dart/Flutter 3.35.7+"; se usa Flutter 3.44.2 stable (cumple). La
  numeración de Dart y Flutter difiere; se aclara en el README.
- Falta configurar el remoto git (el entregable es un link).
