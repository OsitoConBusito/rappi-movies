import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Home temporal del andamiaje (M0): valida que el tema MARQUEE se aplica y que
/// la app arranca. Se reemplaza por la pantalla de catálogo en M1.
class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.colors;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DESIGN SYSTEM — V1.0',
                style: textTheme.labelSmall?.copyWith(color: colors.accent),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('MARQUEE', style: textTheme.displayLarge),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Catálogo de películas y series. Andamiaje listo.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
