# ADR-0003 — Riverpod como state management

- **Estado:** Aceptado
- **Fecha:** 2026-07-01

## Contexto
Necesitamos un manejador de estado testeable, con inyección de dependencias integrada,
soporte de estados asíncronos (loading/data/error) de primera clase y buen encaje con
Clean Architecture. El ejercicio recomienda Riverpod/Hooks.

## Decisión
Usamos **Riverpod** (con `riverpod_generator` para providers tipados y menos boilerplate).

- La **inyección de dependencias** se hace con providers (datasources, repositorios y
  casos de uso se exponen como providers), sin un service locator aparte.
- El estado de pantalla se modela con `AsyncNotifier` / `Notifier`, aprovechando
  `AsyncValue` para mapear directamente a los estados de UI del spec (loading/data/error).
- Los tests sobreescriben providers con `ProviderContainer` y overrides, sin mocks
  globales.

## Consecuencias
- (+) DI y state management en una sola herramienta, coherente y testeable.
- (+) `AsyncValue` elimina el manejo manual de flags `isLoading`/`hasError`.
- (+) Overrides hacen los tests deterministas e independientes.
- (−) Curva de aprendizaje de code-gen y del ciclo de vida de providers. Aceptable.
- **Nota:** se descarta Hooks salvo casos puntuales de UI local; no aporta lo suficiente
  frente al coste de otra dependencia conceptual.
