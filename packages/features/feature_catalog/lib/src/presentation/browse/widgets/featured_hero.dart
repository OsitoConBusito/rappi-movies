import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:feature_catalog/src/presentation/browse/providers/catalog_section_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

/// Hero "Featured Tonight": destaca el primer título Popular del tipo activo.
/// Aspect-ratio adaptativo (4:5 en móvil, 21:9 en tablet/desktop).
class FeaturedHero extends ConsumerWidget {
  const FeaturedHero({required this.type, this.onOpen, super.key});

  final MediaType type;
  final void Function(Media media)? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      catalogSectionProvider(type, MediaCategory.popular),
    );
    final media = state.items.isEmpty ? null : state.items.first;
    final isMobile =
        AppBreakpoints.of(MediaQuery.sizeOf(context).width) ==
        DeviceClass.mobile;
    final aspect = isMobile ? 4 / 5 : 21 / 9;

    if (media == null) {
      return AspectRatio(
        aspectRatio: aspect,
        child: const ShimmerBox(borderRadius: AppRadius.xl),
      );
    }

    final imageBaseUrl = ref.watch(appConfigProvider).tmdbImageBaseUrl;
    final url = media.backdropPath != null
        ? '$imageBaseUrl/w1280${media.backdropPath}'
        : (media.posterPath != null
              ? '$imageBaseUrl/w780${media.posterPath}'
              : null);
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final t = context.t;

    return GestureDetector(
      onTap: () => onOpen?.call(media),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: AspectRatio(
          aspectRatio: aspect,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (url != null)
                CachedNetworkImage(imageUrl: url, fit: BoxFit.cover)
              else
                ColoredBox(color: colors.elevated),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                    stops: [0.3, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.catalog.featured.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.accent,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      media.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (isMobile
                                  ? textTheme.displayMedium
                                  : textTheme.displayLarge)
                              ?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        RatingPill(voteAverage: media.voteAverage),
                        if (media.releaseDate != null) ...[
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            '${media.releaseDate!.year}',
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton.icon(
                      onPressed: () => onOpen?.call(media),
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.accent,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(t.catalog.viewDetail),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
