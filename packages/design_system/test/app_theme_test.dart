import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    test(
      'given the dark theme, then it exposes MarqueeColors with the dark '
      'background token',
      () {
        final theme = AppTheme.dark;
        final colors = theme.extension<MarqueeColors>();

        expect(colors, isNotNull);
        expect(colors!.background, MarqueePalette.darkBackground);
        expect(theme.brightness, Brightness.dark);
      },
    );

    test(
      'given the light theme, then the primary color is the light accent',
      () {
        final theme = AppTheme.light;

        expect(theme.colorScheme.primary, MarqueePalette.lightAccent);
      },
    );
  });
}
