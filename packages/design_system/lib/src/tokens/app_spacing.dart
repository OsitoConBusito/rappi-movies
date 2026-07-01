/// Escala de espaciado sobre una **grilla de 4 puntos** (MARQUEE).
abstract final class AppSpacing {
  static const double unit = 4;

  static const double xs = unit; // 4
  static const double sm = unit * 2; // 8
  static const double md = unit * 3; // 12
  static const double lg = unit * 4; // 16
  static const double xl = unit * 6; // 24
  static const double xxl = unit * 8; // 32
  static const double xxxl = unit * 12; // 48
}

/// Escala de radios de esquina (MARQUEE).
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}
