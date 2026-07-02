import 'package:design_system/design_system.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:feature_catalog/src/presentation/browse/providers/selected_media_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

/// Control segmentado que alterna el tipo de contenido del catálogo entre
/// películas y series (RN-2).
class MediaTypeToggle extends ConsumerWidget {
  const MediaTypeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedMediaTypeProvider);
    final colors = context.colors;
    final t = context.t;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            type: MediaType.movie,
            label: t.catalog.movies,
            selected: selected,
          ),
          _Segment(
            type: MediaType.tv,
            label: t.catalog.series,
            selected: selected,
          ),
        ],
      ),
    );
  }
}

class _Segment extends ConsumerWidget {
  const _Segment({
    required this.type,
    required this.label,
    required this.selected,
  });

  final MediaType type;
  final String label;
  final MediaType selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = type == selected;
    final colors = context.colors;
    final onAccent = Theme.of(context).colorScheme.onPrimary;

    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      child: GestureDetector(
        onTap: () => ref.read(selectedMediaTypeProvider.notifier).select(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isActive ? colors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isActive ? onAccent : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
