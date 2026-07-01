import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tile de un título en un carrusel: poster (con hero + press-scale del DS),
/// pastilla de puntuación superpuesta, y título + año debajo.
class MediaPosterTile extends ConsumerWidget {
  const MediaPosterTile({
    required this.media,
    this.width = 130,
    this.onTap,
    super.key,
  });

  final Media media;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageBaseUrl = ref.watch(appConfigProvider).tmdbImageBaseUrl;
    final posterUrl = media.posterPath == null
        ? null
        : '$imageBaseUrl/w342${media.posterPath}';
    final year = media.releaseDate?.year;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              PosterCard(
                imageUrl: posterUrl,
                heroTag: 'poster-${media.type.name}-${media.id}',
                onTap: onTap,
              ),
              Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
                child: RatingPill(voteAverage: media.voteAverage),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            media.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge,
          ),
          if (year != null)
            Text(
              '$year',
              style: textTheme.labelSmall?.copyWith(
                color: context.colors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}
