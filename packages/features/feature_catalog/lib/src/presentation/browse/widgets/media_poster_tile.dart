import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tile de un título: poster (hero + press-scale), pastilla de puntuación y
/// título + año. Con [width] fijo para carruseles; sin él ocupa el ancho del
/// contenedor (grids). [showTypeBadge] muestra el tipo (film/serie).
class MediaPosterTile extends ConsumerWidget {
  const MediaPosterTile({
    required this.media,
    this.width,
    this.onTap,
    this.showTypeBadge = false,
    super.key,
  });

  final Media media;
  final double? width;
  final VoidCallback? onTap;
  final bool showTypeBadge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageBaseUrl = ref.watch(appConfigProvider).tmdbImageBaseUrl;
    final posterUrl = media.posterPath == null
        ? null
        : '$imageBaseUrl/w342${media.posterPath}';
    final year = media.releaseDate?.year;
    final textTheme = Theme.of(context).textTheme;

    final content = Column(
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
            if (showTypeBadge)
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: _TypeBadge(type: media.type),
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
    );

    return width == null ? content : SizedBox(width: width, child: content);
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final MediaType type;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final icon = type == MediaType.movie
        ? Icons.movie_outlined
        : Icons.tv_outlined;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Icon(icon, size: 13, color: colors.textSecondary),
      ),
    );
  }
}
