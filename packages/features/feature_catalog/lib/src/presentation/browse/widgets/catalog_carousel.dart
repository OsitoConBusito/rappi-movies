import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:feature_catalog/src/presentation/browse/providers/catalog_section_notifier.dart';
import 'package:feature_catalog/src/presentation/browse/state/catalog_section_state.dart';
import 'package:feature_catalog/src/presentation/browse/widgets/media_poster_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sección horizontal (carrusel) de una categoría del catálogo. Mapea el estado
/// del notifier a los estados de UI del spec: loading (skeleton), error
/// (reintento) y data, con paginación por scroll horizontal.
class CatalogCarousel extends ConsumerStatefulWidget {
  const CatalogCarousel({
    required this.type,
    required this.category,
    required this.title,
    this.onOpen,
    super.key,
  });

  final MediaType type;
  final MediaCategory category;
  final String title;
  final void Function(Media media)? onOpen;

  @override
  ConsumerState<CatalogCarousel> createState() => _CatalogCarouselState();
}

class _CatalogCarouselState extends ConsumerState<CatalogCarousel> {
  static const double _tileWidth = 130;
  static const double _carouselHeight = 250;
  static const double _loadMoreThreshold = 320;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _controller.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      unawaited(ref.read(_provider.notifier).loadMore());
    }
  }

  CatalogSectionProvider get _provider =>
      catalogSectionProvider(widget.type, widget.category);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_provider);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title, style: textTheme.titleLarge),
              Text(
                'Ver todo',
                style: textTheme.labelSmall?.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(height: _carouselHeight, child: _buildBody(state)),
      ],
    );
  }

  Widget _buildBody(CatalogSectionState state) {
    if (state.isInitialLoading) {
      return const _CarouselSkeleton(tileWidth: _tileWidth);
    }
    if (state.hasError) return _CarouselError(state: state, onRetry: _retry);
    return _buildList(state);
  }

  void _retry() => unawaited(ref.read(_provider.notifier).retry());

  Widget _buildList(CatalogSectionState state) {
    final itemCount = state.items.length + (state.isLoadingMore ? 1 : 0);
    return ListView.separated(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const SizedBox(
            width: _tileWidth,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final media = state.items[index];
        return MediaPosterTile(
          media: media,
          onTap: () => widget.onOpen?.call(media),
        );
      },
    );
  }
}

class _CarouselSkeleton extends StatelessWidget {
  const _CarouselSkeleton({required this.tileWidth});

  final double tileWidth;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
      itemBuilder: (_, _) => SizedBox(
        width: tileWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AspectRatio(aspectRatio: 2 / 3, child: ShimmerBox()),
            const SizedBox(height: AppSpacing.sm),
            ShimmerBox(width: tileWidth * 0.8, height: 12),
          ],
        ),
      ),
    );
  }
}

class _CarouselError extends StatelessWidget {
  const _CarouselError({required this.state, required this.onRetry});

  final CatalogSectionState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            state.failure?.message ?? 'No pudimos cargar esto ahora.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
