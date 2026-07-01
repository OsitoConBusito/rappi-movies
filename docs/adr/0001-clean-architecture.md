# ADR-0001 — Clean Architecture por capas

- **Estado:** Aceptado
- **Fecha:** 2026-07-01

## Contexto
El ejercicio es pequeño, pero se evalúa la capacidad de estructurar código escalable y
mantenible. Necesitamos separación de responsabilidades clara, dominio testeable sin
depender de Flutter ni de TMDB, y libertad para cambiar detalles (HTTP, persistencia) sin
tocar la lógica de negocio.

## Decisión
Adoptamos Clean Architecture con tres capas por feature:

- **domain** — entidades puras (`Media`, `MediaDetail`), contratos de repositorio
  (interfaces) y casos de uso. Sin dependencias de Flutter ni de paquetes de datos.
- **data** — DTOs (freezed + json_serializable), datasources (`remote` vía Dio,
  `local` vía Drift), *mappers* DTO↔entidad e implementación de los repositorios.
- **presentation** — providers/notifiers de Riverpod, páginas y widgets.

Regla de dependencia: `presentation → domain ← data`. El dominio no conoce a nadie.

## Consecuencias
- (+) Dominio testeable con tests unitarios puros, sin `flutter test` binding.
- (+) Cambiar Drift por otra persistencia, o Dio por otro cliente, no toca dominio ni UI.
- (+) Los mappers aíslan el formato de TMDB del modelo interno.
- (−) Más *boilerplate* (interfaces + mappers). Se acepta como coste de la escalabilidad
  que el ejercicio pide demostrar; se mantiene proporcionado (sin capas ceremoniales
  extra tipo "manager"/"helper").
