# ADR-0008 — slang para internacionalización (i18n)

- **Estado:** Aceptado
- **Fecha:** 2026-07-01

## Contexto
La app arranca con UI en español pero debe soportar al menos español e inglés.
Necesitamos i18n *type-safe* (sin claves string sueltas), integrada con Flutter y con el
locale del dispositivo, y que además permita derivar el idioma de los **datos** de TMDB
(RN-4 del spec).

## Decisión
Usamos **slang** en un paquete compartido `packages/i18n`.

- Traducciones en JSON: `es.i18n.json` (base) + `en.i18n.json`; acceso type-safe `t.x.y`.
- `TranslationProvider` + `context.t` para reactividad ante cambios de locale; el
  `MaterialApp` toma `locale`/`supportedLocales` de slang + `GlobalMaterialLocalizations`.
- La generación se hace con el **CLI de slang** (`dart run slang`, expuesto como
  `melos run i18n`), no con `slang_build_runner`, para evitar el *output diferido por
  locale* de build_runner y tener acceso síncrono en tests y arranque.
- **RN-4:** el datasource de TMDB toma el `languageCode` del locale activo.
- Los `Failure` del dominio se mapean a mensajes localizados **en la capa de
  presentación** (extensión `FailureL10n`); el dominio no depende de i18n y su `message`
  queda como fallback de log.

## Consecuencias
- (+) Strings type-safe, sin claves mágicas; el compilador caza typos y faltantes.
- (+) Un único origen de traducciones para `app` y las features.
- (+) RN-4 satisfecha: datos e interfaz siguen el locale.
- (+) Reactiva el agente `i18n-checker` reutilizable de espectaculapp.
- (−) La generación de slang va por CLI, aparte de build_runner (un script de Melos y un
  paso extra en CI). Coste acotado.
- (−) Los locales no-base se cargan de forma diferida; se resuelve esperando el locale al
  arrancar con `await LocaleSettings.useDeviceLocale()`.
