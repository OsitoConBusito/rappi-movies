/// Clase de dispositivo según el ancho disponible (mobile-first).
enum DeviceClass { mobile, tabletPortrait, tabletLandscape, desktop }

/// Breakpoints responsive de MARQUEE. Los umbrales caen entre los anchos de
/// frame del diseño (390 / 834 / 1194 / 1360).
abstract final class AppBreakpoints {
  static const double tabletPortrait = 600;
  static const double tabletLandscape = 900;
  static const double desktop = 1200;

  /// Ancho del sidebar (desktop) y del icon rail (tablet landscape).
  static const double sidebarWidth = 250;
  static const double railWidth = 88;

  static DeviceClass of(double width) {
    if (width >= desktop) return DeviceClass.desktop;
    if (width >= tabletLandscape) return DeviceClass.tabletLandscape;
    if (width >= tabletPortrait) return DeviceClass.tabletPortrait;
    return DeviceClass.mobile;
  }

  /// Columnas de grid de posters por breakpoint (2 / 4 / 5 / 6), según diseño.
  static int gridColumns(double width) => switch (of(width)) {
    DeviceClass.desktop => 6,
    DeviceClass.tabletLandscape => 5,
    DeviceClass.tabletPortrait => 4,
    DeviceClass.mobile => 2,
  };
}
