import 'package:flutter/material.dart';

/// Paleta cruda del design system **MARQUEE**. No se consume directamente en la
/// UI: se expone de forma semántica vía [MarqueeColors] y el [ColorScheme].
abstract final class MarqueePalette {
  // Dark
  static const Color darkBackground = Color(0xFF0C0C0F);
  static const Color darkSurface = Color(0xFF151519);
  static const Color darkElevated = Color(0xFF1D1D22);
  static const Color darkHover = Color(0xFF26262C);
  static const Color darkTextPrimary = Color(0xFFF5F4F2);
  static const Color darkTextSecondary = Color(0xFFA6A5AC);
  static const Color darkTextMuted = Color(0xFF6C6B73);
  static const Color darkAccent = Color(0xFFF5B23C);
  static const Color darkAccentText = Color(0xFFF5B23C);

  // Light
  static const Color lightBackground = Color(0xFFF6F5F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFFBFAF7);
  static const Color lightHover = Color(0xFFEFEDE8);
  static const Color lightTextPrimary = Color(0xFF1A1815);
  static const Color lightTextSecondary = Color(0xFF57544E);
  static const Color lightTextMuted = Color(0xFF88887F);
  static const Color lightAccent = Color(0xFFEEA82C);
  static const Color lightAccentText = Color(0xFFA9760F);

  // Feedback (compartido)
  static const Color error = Color(0xFFE5484D);
  static const Color success = Color(0xFF35C77F);
}

/// Tokens de color semánticos de MARQUEE, expuestos como [ThemeExtension] para
/// resolverse por tema (dark/light) y consumirse con `context.colors`.
@immutable
class MarqueeColors extends ThemeExtension<MarqueeColors> {
  const MarqueeColors({
    required this.background,
    required this.surface,
    required this.elevated,
    required this.hover,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentText,
  });

  factory MarqueeColors.dark() => const MarqueeColors(
    background: MarqueePalette.darkBackground,
    surface: MarqueePalette.darkSurface,
    elevated: MarqueePalette.darkElevated,
    hover: MarqueePalette.darkHover,
    textPrimary: MarqueePalette.darkTextPrimary,
    textSecondary: MarqueePalette.darkTextSecondary,
    textMuted: MarqueePalette.darkTextMuted,
    accent: MarqueePalette.darkAccent,
    accentText: MarqueePalette.darkAccentText,
  );

  factory MarqueeColors.light() => const MarqueeColors(
    background: MarqueePalette.lightBackground,
    surface: MarqueePalette.lightSurface,
    elevated: MarqueePalette.lightElevated,
    hover: MarqueePalette.lightHover,
    textPrimary: MarqueePalette.lightTextPrimary,
    textSecondary: MarqueePalette.lightTextSecondary,
    textMuted: MarqueePalette.lightTextMuted,
    accent: MarqueePalette.lightAccent,
    accentText: MarqueePalette.lightAccentText,
  );

  final Color background;
  final Color surface;
  final Color elevated;
  final Color hover;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentText;

  @override
  MarqueeColors copyWith({
    Color? background,
    Color? surface,
    Color? elevated,
    Color? hover,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? accentText,
  }) {
    return MarqueeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      elevated: elevated ?? this.elevated,
      hover: hover ?? this.hover,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      accentText: accentText ?? this.accentText,
    );
  }

  @override
  MarqueeColors lerp(covariant ThemeExtension<MarqueeColors>? other, double t) {
    if (other is! MarqueeColors) return this;
    return MarqueeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      elevated: Color.lerp(elevated, other.elevated, t)!,
      hover: Color.lerp(hover, other.hover, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
    );
  }
}
