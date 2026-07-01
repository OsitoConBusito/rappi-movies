import 'package:flutter/material.dart';

/// Tipografía de MARQUEE: **Sora** para títulos/display e **IBM Plex Sans** para
/// cuerpo y etiquetas. Ambas fuentes van empaquetadas como assets del design
/// system (offline-first: no se descargan en runtime).
abstract final class AppTypography {
  static const String _fontPackage = 'design_system';
  static const String _displayFamily = 'Sora';
  static const String _bodyFamily = 'IBMPlexSans';

  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) {
    TextStyle display(double size, FontWeight weight, {double height = 1.1}) =>
        TextStyle(
          fontFamily: _displayFamily,
          package: _fontPackage,
          fontSize: size,
          fontWeight: weight,
          color: primary,
          height: height,
        );

    TextStyle body(
      double size,
      FontWeight weight, {
      Color? color,
      double height = 1.4,
      double letterSpacing = 0,
    }) => TextStyle(
      fontFamily: _bodyFamily,
      package: _fontPackage,
      fontSize: size,
      fontWeight: weight,
      color: color ?? primary,
      height: height,
      letterSpacing: letterSpacing,
    );

    return TextTheme(
      displayLarge: display(40, FontWeight.w700, height: 1.05),
      displayMedium: display(32, FontWeight.w700),
      headlineMedium: display(24, FontWeight.w600),
      titleLarge: display(18, FontWeight.w600),
      titleMedium: body(16, FontWeight.w600),
      bodyLarge: body(15, FontWeight.w400),
      bodyMedium: body(14, FontWeight.w400, color: secondary),
      labelLarge: body(13, FontWeight.w600),
      labelSmall: body(
        11,
        FontWeight.w500,
        color: secondary,
        letterSpacing: 0.5,
      ),
    );
  }
}
