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

### 2026-07-01 — i18n con slang (fundación cross-cutting)

- **Qué se pidió a la IA:** añadir internacionalización con **slang** (no se había
  considerado en el plan), al menos español e inglés.
- **Aporte de la IA:** paquete compartido `packages/i18n` con slang; traducciones `es`
  (base) + `en`; `TranslationProvider` + `context.t`; migración de los strings de M1;
  mapeo `Failure`→i18n en presentación; conexión de **RN-4** (idioma de los datos de TMDB
  al locale activo). ADR-0008.
- **Decisiones humanas:** slang (preferencia del autor), base `es` + `en`, paquete `i18n`
  compartido. Generación por el CLI de slang (no build_runner) para acceso síncrono.
- **Verificación:** tests de traducciones + suite completa (15) verde; `melos analyze`
  limpio; build previo del catálogo intacto.

### 2026-07-01 — M3: Detalle (HU-2), navegación y animaciones

- **Qué se pidió a la IA:** pantalla de detalle, bottom nav y animaciones,
  dominio-primero; además el selector manual de idioma.
- **Aporte de la IA:**
  - Capa de datos del detalle (endpoint con `append_to_response=credits`, DTOs
    freezed, mapper, `getDetail` con caché) y `MediaDetailPage` (`SliverAppBar`
    colapsable, **Hero** del poster desde el listado, géneros/sinopsis/reparto).
  - Router `go_router` con `StatefulShellRoute` (bottom nav Inicio/Buscar) y
    ruta de detalle de nivel superior; `FadeSlideIn` (stagger) en el detalle.
  - Selector de idioma (español por defecto) persistente y reactivo a TMDB.
- **Decisiones humanas:**
  - Bottom nav con los destinos en alcance (Home/Search); Saved/You fuera del
    alcance del enunciado, documentados.
  - Idioma **español por defecto** con selector manual (ignora el locale del
    sistema).
  - Navegación desacoplada: la feature emite `onOpenMedia`, el app resuelve la
    ruta (la feature no conoce go_router). `Failure` implementa `Exception`.
- **Verificación:** 20 tests verdes; `melos analyze` limpio; el build web compila
  el grafo completo (router + detalle) con el token real.

### 2026-07-01 — M4: offline-first (Drift SSOT) + conectividad

- **Qué se pidió a la IA:** offline-first real (móvil + web WASM) y detección de
  conectividad, aprovechando el contrato reactivo ya diseñado.
- **Aporte de la IA:**
  - `CatalogDatabase` (Drift): tablas de ítems, orden por categoría y detalle.
  - **Swap del repo a single-source-of-truth**: `watchCategory` emite desde Drift
    y `refreshCategory` actualiza la caché — **sin tocar dominio ni UI**, tal como
    el contrato reactivo lo previó desde M1. `getDetail` sirve del caché offline.
  - `ConnectivityService` (reachability real, ADR-0007) + `OfflineBanner` no
    intrusivo; assets WASM (`sqlite3.wasm` + `drift_worker.js`) para web.
- **Decisiones humanas:** Drift SSOT como diferenciador técnico; banner no
  intrusivo (offline con caché) reconciliado con la pantalla full-screen del
  diseño (caso sin caché).
- **Verificación:** test de integración con Drift en memoria (offline mantiene la
  caché); 22 tests verdes; el build web compila Drift-on-web.

### 2026-07-01 — M5: Buscador (HU-3)

- **Qué se pidió a la IA:** buscador por nombre con debounce, resultados
  combinados con filtro por tipo, y estados.
- **Aporte de la IA:** `repo.search` sobre `/search/multi` (filtra personas, mapea
  movie/tv, no cachea por RN-5); `SearchResults` notifier con debounce (400 ms) y
  `SelectedSearchFilter`; `SearchPage` con campo, chips (Todo/Películas/Series),
  grid con badge de tipo, navegación al detalle y estados inicial/vacío/offline.
- **Decisiones humanas:** filtro Todo/Películas/Series (People fuera de alcance);
  badge de tipo por icono (agnóstico al idioma).
- **Verificación:** tests de `search` (filtra personas; query vacía no pega a la
  red); 24 tests verdes; el build web compila. **Las 3 historias del enunciado
  quedan completas.**

### 2026-07-01 — Pulido de detalle: ficha, similares y parallax

- **Qué se pidió a la IA:** más información en el detalle para que el scroll tenga
  sentido, y un efecto **parallax** en el backdrop al hacer scroll.
- **Aporte de la IA:** ficha técnica (director desde `crew`, idioma original,
  estado, votos) y carrusel **"Similares"** (`recommendations` de TMDB, con
  navegación y Hero); parallax del backdrop (default de `FlexibleSpaceBar`) +
  `stretch`/zoom al over-scroll. También el fix del Hero al **entrar** (poster
  desde el `preview` durante la carga).
- **Decisión (deep-link):** el `Media` se pasa como `extra` en la navegación
  **solo como optimización** para que el Hero tenga poster en el frame 0. La ruta
  es 100% funcional con `type + id` (deep-link / recarga → cae al loading y
  fetchea); `extra` nunca es dependencia de datos. Se descartó leer el preview de
  Drift porque su lectura async rompería el timing del Hero.
- **Verificación:** 24 tests verdes; `melos analyze` limpio; el build web compila.

<!-- Próximas entradas se añaden aquí a medida que avanzamos. -->
