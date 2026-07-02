# Spec — Catálogo de Películas y Series

- **Estado:** Implementado
- **Autor:** Juan Cano (con asistencia de Claude)
- **Última actualización:** 2026-07-02
- **Reconciliado contra código:** 2026-07-02 (HU-1, HU-2, HU-3, offline-first/RN-5 y responsive de 4 breakpoints —
  incluyendo scroll infinito en tablet/desktop— implementados)

## 1. Objetivo

Aplicación de catálogo de **películas y series** (datos de TMDB) que permite explorar
títulos populares y mejor valorados, ver el detalle de cada uno y buscar por nombre.
La app es **offline-first**, **responsive** (móvil, tablet, desktop, web) y soporta
**modo claro/oscuro**.

Este spec es la fuente de verdad de comportamiento. El código debe reflejarlo; cuando
diverjan, se actualiza el spec o el código, nunca se dejan en silencio.

## 2. Alcance

### Dentro de alcance
- Catálogo con dos categorías: **Popular** y **Top Rated**.
- Dos tipos de contenido: **películas** (`movie`) y **series** (`tv`), unificados en un
  dominio genérico `Media` con discriminador `MediaType`.
- **Detalle** de un título (backdrop, sinopsis, géneros, puntuación, reparto).
- **Buscador** por nombre, con resultados combinados o filtrados por tipo.
- **Offline-first**: lo ya visto se sirve desde caché local (Drift) sin conexión.
- **Indicador de conectividad**: la app sabe y comunica si hay internet real.
- Paginación / scroll infinito en listados.
- Tema claro y oscuro.

### Fuera de alcance (documentado en README como "cómo lo haría")
- Autenticación / sesión de usuario TMDB, listas personales, ratings del usuario.
- Reproducción de tráilers.
- Notificaciones push.

## 3. Actores y contexto
- **Usuario anónimo**: única persona usuaria. No hay login.
- **TMDB API v3**: fuente de datos remota. Requiere API Read Access Token.

## 4. Historias de usuario

### HU-1 — Explorar catálogo
> Como usuario, quiero ver películas y series **Popular** y **Top Rated**, para
> descubrir contenido.

**Criterios de aceptación**
- Dado que abro la app con conexión, cuando carga el catálogo, entonces veo carruseles
  de *Popular* y *Top Rated* por tipo de contenido.
- Dado que hago scroll hasta el final de un listado, cuando hay más páginas, entonces se
  cargan más resultados (paginación) sin bloquear la UI.
- Dado que no hay conexión, cuando abro la app, entonces veo el último catálogo cacheado
  y un aviso no intrusivo de "sin conexión".

### HU-2 — Ver detalle
> Como usuario, quiero ver el detalle de un título, para conocer su sinopsis y datos.

**Criterios de aceptación**
- Dado un título en un listado, cuando lo selecciono, entonces navego a su detalle con
  transición de elemento compartido (poster).
- Dado el detalle, cuando carga, entonces veo backdrop, título, puntuación, géneros,
  sinopsis y reparto principal.
- Dado que abrí ese detalle antes, cuando no hay conexión, entonces se muestra desde
  caché.

### HU-3 — Buscar
> Como usuario, quiero buscar títulos por nombre, para encontrar algo concreto.

**Criterios de aceptación**
- Dado el buscador, cuando escribo, entonces los resultados se actualizan con *debounce*
  (evitar una petición por tecla).
- Dado un término sin resultados, cuando la búsqueda termina, entonces veo un estado
  vacío claro.
- Dado que estoy sin conexión, cuando busco, entonces veo un mensaje indicando que la
  búsqueda requiere conexión (no se cachea la búsqueda arbitraria).

## 5. Reglas de negocio
- **RN-1** Categorías soportadas: `popular`, `topRated`. (`BookingStatus`-style enum.)
- **RN-2** Tipos soportados: `movie`, `tv`.
- **RN-3** La puntuación se muestra sobre 10 con un decimal (p. ej. `8.4`).
- **RN-4** El idioma de los datos se pide a TMDB según el locale del dispositivo
  (`es`/`en`), con `en` como fallback.
- **RN-5** Offline-first: el repositorio es la única fuente de verdad y emite desde la
  caché local; la red actualiza la caché en segundo plano.

## 6. Estados de UI (por pantalla)
Cada pantalla de datos contempla explícitamente: `loading` (skeleton shimmer), `data`,
`empty`, `error` (con reintento), y `offline` (banner + datos cacheados si existen).

## 7. Modelo de dominio (borrador)
- `Media { id, type: MediaType, title, overview, posterPath?, backdropPath?,
  voteAverage, releaseDate?, genreIds }`
- `MediaDetail extends Media { genres, runtime?, cast: List<CastMember> }`
- `MediaCategory { popular, topRated }`
- `MediaType { movie, tv }`

## 8. No funcionales
- **Responsive**: breakpoints móvil / tablet portrait / tablet landscape / desktop.
- **Rendimiento**: listados con imágenes cacheadas y construcción perezosa; scroll fluido.
- **Accesibilidad**: semántica en elementos interactivos, tamaños táctiles ≥ 48dp.
- **Testabilidad**: dominio y data testeables sin Flutter; UI con widget/golden tests.
- **Seguridad**: el token de TMDB nunca se commitea (`--dart-define-from-file`).

## 9. Métrica de "hecho"
- Las 3 historias con sus criterios cubiertos por tests (unit + widget) verdes.
- App corre en iOS/Android/web y es responsive en los 4 breakpoints.
- Modo claro/oscuro funcional.
- Offline verificable (avión → sigue mostrando lo cacheado).
- CI en verde (analyze + tests).

## 10. Preguntas abiertas
- ¿Buscador unificado (pelis+series) o con toggle de tipo? → Decisión inicial: unificado
  con filtro por tipo. Revisable.
- ¿Persistimos resultados de búsqueda? → No en v1 (RN-5).
