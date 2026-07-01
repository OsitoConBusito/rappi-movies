import 'package:design_system/src/tokens/app_colors.dart';
import 'package:design_system/src/tokens/app_typography.dart';
import 'package:flutter/material.dart';

/// Construye los [ThemeData] claro y oscuro a partir de los tokens de MARQUEE.
abstract final class AppTheme {
  static ThemeData get dark => _build(Brightness.dark, MarqueeColors.dark());

  static ThemeData get light => _build(Brightness.light, MarqueeColors.light());

  static ThemeData _build(Brightness brightness, MarqueeColors colors) {
    final isDark = brightness == Brightness.dark;
    final onAccent = isDark
        ? MarqueePalette.darkBackground
        : MarqueePalette.lightSurface;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.accent,
      onPrimary: onAccent,
      secondary: colors.accent,
      onSecondary: onAccent,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      error: MarqueePalette.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      textTheme: AppTypography.textTheme(
        primary: colors.textPrimary,
        secondary: colors.textSecondary,
      ),
      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }
}

/// Acceso ergonómico a los tokens de color del tema activo: `context.colors`.
extension MarqueeColorsX on BuildContext {
  MarqueeColors get colors => Theme.of(this).extension<MarqueeColors>()!;
}
