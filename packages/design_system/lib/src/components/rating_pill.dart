import 'package:design_system/src/theme/app_theme.dart';
import 'package:design_system/src/tokens/app_spacing.dart';
import 'package:flutter/material.dart';

/// Pastilla de puntuación (RN-3): muestra la nota sobre 10 con un decimal,
/// precedida de una estrella en color accent, sobre una superficie translúcida.
class RatingPill extends StatelessWidget {
  const RatingPill({required this.voteAverage, super.key});

  final double voteAverage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs / 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, size: 13, color: colors.accent),
            const SizedBox(width: AppSpacing.xs),
            Text(
              voteAverage.toStringAsFixed(1),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
