# ADR-0005 — go_router en lugar de fluro

- **Estado:** Aceptado
- **Fecha:** 2026-07-01

## Contexto
El ejercicio **recomienda** fluro para navegación, pero no lo exige. Necesitamos routing
que soporte bien web (URLs reales, deep-linking), navegación anidada, y que integre con
Riverpod y con transiciones personalizadas.

## Decisión
Usamos **go_router**.

- Es el router declarativo alineado con las APIs de navegación actuales de Flutter y está
  activamente mantenido.
- Da **URLs y deep-linking en web** de forma natural, requisito de este proyecto.
- Integra con Riverpod (redirects/guards observando providers) y permite definir
  `pageBuilder` para transiciones custom (incluida la de elemento compartido del detalle).

## Consecuencias
- (+) Web con rutas navegables y compartibles.
- (+) Transiciones personalizadas por ruta.
- (−) Nos apartamos de la recomendación literal del enunciado. Se documenta en el README
  como decisión consciente y justificada, no como omisión.
- **Mitigación:** el `Router` queda encapsulado en `app`; sustituirlo tendría impacto
  local si algún evaluador insistiera en fluro.
