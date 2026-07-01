import 'package:design_system/src/theme/app_theme.dart';
import 'package:design_system/src/tokens/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Placeholder animado (skeleton) que respeta los colores del tema activo.
/// Se usa para el estado `loading` de listados y detalles.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppRadius.md,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.elevated,
      highlightColor: colors.hover,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
