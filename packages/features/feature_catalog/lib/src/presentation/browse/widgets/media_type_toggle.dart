import 'package:design_system/design_system.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:feature_catalog/src/presentation/browse/providers/selected_media_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

/// Control segmentado que alterna el tipo de contenido del catálogo entre
/// películas y series (RN-2), con la píldora deslizante del design system.
class MediaTypeToggle extends ConsumerWidget {
  const MediaTypeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedMediaTypeProvider);
    final t = context.t;

    return SegmentedPills<MediaType>(
      selected: selected,
      onSelected: (type) =>
          ref.read(selectedMediaTypeProvider.notifier).select(type),
      options: [
        SegmentOption(
          value: MediaType.movie,
          label: t.catalog.movies,
          icon: Icons.movie_outlined,
        ),
        SegmentOption(
          value: MediaType.tv,
          label: t.catalog.series,
          icon: Icons.live_tv_outlined,
        ),
      ],
    );
  }
}
