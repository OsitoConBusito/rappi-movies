import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_catalog/src/data/providers/catalog_data_providers.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:feature_catalog/src/domain/entities/media_detail.dart';
import 'package:feature_catalog/src/presentation/browse/failure_l10n.dart';
import 'package:feature_catalog/src/presentation/browse/widgets/media_poster_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

/// Pantalla de detalle de un título (HU-2): backdrop colapsable, poster con
/// transición Hero desde el listado, puntuación, géneros, sinopsis y reparto.
class MediaDetailPage extends ConsumerWidget {
  const MediaDetailPage({
    required this.type,
    required this.id,
    this.preview,
    this.onOpenMedia,
    super.key,
  });

  final MediaType type;
  final int id;

  /// Datos del listado (si se navegó desde ahí). Permiten mostrar el poster con
  /// la transición Hero de inmediato mientras carga el detalle completo.
  final Media? preview;

  /// Navegación al detalle de un título relacionado (carrusel "similares").
  final void Function(Media media)? onOpenMedia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(mediaDetailProvider(type, id));
    final media = preview;

    return Scaffold(
      body: detail.when(
        loading: () => media == null
            ? const Center(child: CircularProgressIndicator())
            : _DetailLoading(preview: media),
        error: (error, _) => _DetailError(
          error: error,
          onRetry: () => ref.invalidate(mediaDetailProvider(type, id)),
        ),
        data: (loaded) => _DetailContent(detail: loaded, onOpen: onOpenMedia),
      ),
    );
  }
}

/// Estado de carga que ya muestra el poster (Hero) + título + puntuación desde
/// el `preview`, con shimmer para el resto. Da destino inmediato a la
/// transición Hero al entrar.
class _DetailLoading extends ConsumerWidget {
  const _DetailLoading({required this.preview});

  final Media preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageBaseUrl = ref.watch(appConfigProvider).tmdbImageBaseUrl;
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        _DetailBackdropBar(
          url: preview.backdropPath == null
              ? null
              : '$imageBaseUrl/w780${preview.backdropPath}',
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: PosterCard(
                        imageUrl: preview.posterPath == null
                            ? null
                            : '$imageBaseUrl/w342${preview.posterPath}',
                        heroTag: 'poster-${preview.type.name}-${preview.id}',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(preview.title, style: textTheme.headlineMedium),
                          const SizedBox(height: AppSpacing.sm),
                          RatingPill(voteAverage: preview.voteAverage),
                          const SizedBox(height: AppSpacing.md),
                          const ShimmerBox(width: 120, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                const ShimmerBox(height: 14),
                const SizedBox(height: AppSpacing.sm),
                const ShimmerBox(height: 14),
                const SizedBox(height: AppSpacing.sm),
                const ShimmerBox(width: 200, height: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.detail, this.onOpen});

  final MediaDetail detail;
  final void Function(Media media)? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageBaseUrl = ref.watch(appConfigProvider).tmdbImageBaseUrl;
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final year = detail.releaseDate?.year;

    return CustomScrollView(
      slivers: [
        _DetailBackdropBar(
          url: detail.backdropPath == null
              ? null
              : '$imageBaseUrl/w780${detail.backdropPath}',
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(detail: detail, imageBaseUrl: imageBaseUrl, year: year),
                const SizedBox(height: AppSpacing.lg),
                if (detail.genres.isNotEmpty)
                  FadeSlideIn(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: _GenreChips(genres: detail.genres),
                    ),
                  ),
                if (detail.overview.isNotEmpty)
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 80),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                      child: Text(
                        detail.overview,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                if (detail.cast.isNotEmpty)
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 160),
                    child: _CastList(
                      cast: detail.cast,
                      imageBaseUrl: imageBaseUrl,
                    ),
                  ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 220),
                  child: _InfoGrid(detail: detail),
                ),
                if (detail.recommendations.isNotEmpty)
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 300),
                    child: _SimilarCarousel(
                      medias: detail.recommendations,
                      onOpen: onOpen,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailBackdropBar extends StatelessWidget {
  const _DetailBackdropBar({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: colors.surface,
      // parallax (colapso) y zoomBackground (over-scroll) son los defaults de
      // FlexibleSpaceBar; solo habilitamos el stretch en el SliverAppBar.
      flexibleSpace: FlexibleSpaceBar(
        background: _Backdrop(url: url, surface: colors.background),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.detail});

  final MediaDetail detail;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final rows = <(String, String)>[
      if (detail.director != null) (t.detail.director, detail.director!),
      if (detail.originalLanguage != null)
        (t.detail.language, detail.originalLanguage!.toUpperCase()),
      if (detail.status != null) (t.detail.status, detail.status!),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(
                      label,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                  Expanded(child: Text(value, style: textTheme.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SimilarCarousel extends StatelessWidget {
  const _SimilarCarousel({required this.medias, required this.onOpen});

  final List<Media> medias;
  final void Function(Media media)? onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t.detail.similar,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: medias.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final media = medias[index];
                return MediaPosterTile(
                  media: media,
                  width: 120,
                  onTap: () => onOpen?.call(media),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.url, required this.surface});

  final String? url;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (url != null)
          CachedNetworkImage(imageUrl: url!, fit: BoxFit.cover)
        else
          ColoredBox(color: surface),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, surface],
              stops: const [0.45, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.detail,
    required this.imageBaseUrl,
    required this.year,
  });

  final MediaDetail detail;
  final String imageBaseUrl;
  final int? year;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final meta = [
      if (year != null) '$year',
      if (detail.runtime != null) '${detail.runtime} min',
    ].join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: PosterCard(
            imageUrl: detail.posterPath == null
                ? null
                : '$imageBaseUrl/w342${detail.posterPath}',
            heroTag: 'poster-${detail.type.name}-${detail.id}',
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detail.title, style: textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              RatingPill(voteAverage: detail.voteAverage),
              if (meta.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  meta,
                  style: textTheme.labelSmall?.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
              ],
              if (detail.tagline != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  detail.tagline!,
                  style: textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _GenreChips extends StatelessWidget {
  const _GenreChips({required this.genres});

  final List<Genre> genres;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final genre in genres)
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.elevated,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                genre.name,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
      ],
    );
  }
}

class _CastList extends StatelessWidget {
  const _CastList({required this.cast, required this.imageBaseUrl});

  final List<CastMember> cast;
  final String imageBaseUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t.detail.cast,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cast.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) => _CastTile(
              member: cast[index],
              imageBaseUrl: imageBaseUrl,
            ),
          ),
        ),
      ],
    );
  }
}

class _CastTile extends StatelessWidget {
  const _CastTile({required this.member, required this.imageBaseUrl});

  final CastMember member;
  final String imageBaseUrl;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.colors;
    final url = member.profilePath == null
        ? null
        : '$imageBaseUrl/w185${member.profilePath}';

    return SizedBox(
      width: 84,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: AspectRatio(
              aspectRatio: 1,
              child: url == null
                  ? ColoredBox(
                      color: colors.elevated,
                      child: const Center(child: Icon(Icons.person_outline)),
                    )
                  : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            member.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall,
          ),
          Text(
            member.character,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _DetailError extends ConsumerWidget {
  const _DetailError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final message = error is Failure
        ? (error as Failure).localized(t)
        : t.errors.loadFailed;

    return SafeArea(
      child: Stack(
        children: [
          const BackButton(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                TextButton(onPressed: onRetry, child: Text(t.common.retry)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
