# ADR-0006 — Result (fpdart) para manejo de errores

- **Estado:** Aceptado
- **Fecha:** 2026-07-01

## Contexto
Los fallos esperados (sin conexión, 404, timeout, parseo) no deben propagarse como
excepciones que ensucien la lógica ni obliguen a `try/catch` por todos lados. Queremos
rutas de fallo explícitas y tipadas, y reservar las excepciones para errores de
programación o de infraestructura verdaderamente inesperados.

## Decisión
Usamos **`Either<Failure, T>`** de **fpdart** como tipo de retorno de repositorios y casos
de uso.

- Jerarquía de `Failure` tipada: `NetworkFailure`, `NotFoundFailure`, `ServerFailure`,
  `CacheFailure`, `UnknownFailure`, con mensajes accionables.
- Los datasources traducen errores de Dio/Drift a `Failure`; el dominio nunca ve una
  excepción de infraestructura.
- La capa de presentación mapea `Either` a `AsyncValue` para la UI.

## Consecuencias
- (+) La firma de cada función documenta que puede fallar y cómo.
- (+) La lógica queda limpia, sin `try/catch` disperso (regla de estilo del proyecto).
- (+) Exhaustividad: el compilador ayuda a no olvidar el caso de error.
- (−) Otra dependencia y un estilo funcional que el equipo debe conocer. Aceptable y
  aislado en fronteras de capa.
