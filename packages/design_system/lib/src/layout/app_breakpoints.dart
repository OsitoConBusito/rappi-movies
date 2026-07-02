import 'package:flutter/widgets.dart';

/// Breakpoints responsive de MARQUEE.
abstract final class AppBreakpoints {
  static const double tablet = 600;
  static const double desktop = 1000;

  /// Ancho máximo del contenido: en pantallas grandes se centra en vez de
  /// estirarse a todo lo ancho.
  static const double maxContentWidth = 920;

  /// Columnas para grids de posters según el ancho disponible (móvil 3,
  /// tablet 4, desktop 5) — coincide con el diseño.
  static int gridColumns(double width) {
    if (width >= desktop) return 5;
    if (width >= tablet) return 4;
    return 3;
  }
}

/// Centra y limita el ancho del contenido en pantallas grandes.
class CenteredContent extends StatelessWidget {
  const CenteredContent({
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
