# ADR-0007 — Estrategia de detección de conectividad

- **Estado:** Aceptado
- **Fecha:** 2026-07-01

## Contexto
Un requisito es "saber si tiene o no internet" y comunicarlo. El error común es usar solo
`connectivity_plus`, que informa del **tipo de interfaz** de red (wifi/móvil/ninguna) pero
**no** si hay acceso real a internet: puede haber wifi conectado sin salida a la red.

## Decisión
Combinamos dos señales:

1. **`connectivity_plus`** — detecta cambios de interfaz (reacciona rápido a activar/quitar
   red).
2. **`internet_connection_checker_plus`** — verifica alcanzabilidad real (petición ligera a
   hosts fiables) para confirmar que hay internet, no solo interfaz.

Se expone un `ConnectivityService` en `core` que emite un `Stream<ConnectionStatus>`
(`online` / `offline`), consumido por un provider de Riverpod. La UI muestra un banner no
intrusivo en `offline` y el repositorio ajusta su estrategia (servir de caché).

## Consecuencias
- (+) Distingue "hay red" de "hay internet", evitando falsos positivos.
- (+) Fuente única de verdad de conectividad para toda la app.
- (−) La verificación de alcanzabilidad hace peticiones periódicas ligeras; se configura un
  intervalo razonable para no gastar batería/datos.
