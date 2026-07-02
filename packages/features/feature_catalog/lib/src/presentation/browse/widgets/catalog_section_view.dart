import 'package:design_system/design_system.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:feature_catalog/src/presentation/browse/failure_l10n.dart';
import 'package:feature_catalog/src/presentation/browse/providers/catalog_section_notifier.dart';
import 'package:feature_catalog/src/presentation/browse/state/catalog_section_state.dart';
import 'package:feature_catalog/src/presentation/browse/widgets/catalog_carousel.dart';
import 'package:feature_catalog/src/presentation/browse/widgets/media_poster_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

/// Sección del catálogo **adaptativa**: carrusel horizontal en móvil, grid
/// (4/5/6 columnas) en tablet y desktop.
class CatalogSectionView extends StatelessWidget {
  const CatalogSectionView({
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
  Widget build(BuildContext context) {
    final isMobile =
        AppBreakpoints.of(MediaQuery.sizeOf(context).width) ==
        DeviceClass.mobile;

    if (isMobile) {
      return CatalogCarousel(
        type: type,
        category: category,
        title: title,
        onOpen: onOpen,
      );
    }
    return _CatalogGrid(
      type: type,
      category: category,
      title: title,
      onOpen: onOpen,
    );
  }
}

class _CatalogGrid extends ConsumerWidget {
  const _CatalogGrid({
    required this.type,
    required this.category,
    required this.title,
    this.onOpen,
  });

  final MediaType type;
  final MediaCategory category;
  final String title;
  final void Function(Media media)? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogSectionProvider(type, category));
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: textTheme.titleLarge),
              Text(
                context.t.common.seeAll,
                style: textTheme.labelSmall?.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildBody(context, ref, state),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    CatalogSectionState s,
  ) {
    if (s.isInitialLoading) return const _GridSkeleton();
    if (s.hasError) {
      return _GridError(
        message: s.failure?.localized(context.t) ?? context.t.errors.loadFailed,
        onRetry: () =>
            ref.read(catalogSectionProvider(type, category).notifier).retry(),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppBreakpoints.gridColumns(constraints.maxWidth),
          crossAxisSpacing: AppSpacing.lg,
          mainAxisSpacing: AppSpacing.lg,
          childAspectRatio: 0.52,
        ),
        itemCount: s.items.length,
        itemBuilder: (context, index) => MediaPosterTile(
          media: s.items[index],
          onTap: () => onOpen?.call(s.items[index]),
        ),
      ),
    );
  }
}

class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppBreakpoints.gridColumns(constraints.maxWidth),
          crossAxisSpacing: AppSpacing.lg,
          mainAxisSpacing: AppSpacing.lg,
          childAspectRatio: 0.52,
        ),
        itemCount: AppBreakpoints.gridColumns(constraints.maxWidth) * 2,
        itemBuilder: (context, index) => const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: 2 / 3, child: ShimmerBox()),
            SizedBox(height: AppSpacing.sm),
            ShimmerBox(width: 80, height: 12),
          ],
        ),
      ),
    );
  }
}

class _GridError extends StatelessWidget {
  const _GridError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          TextButton(onPressed: onRetry, child: Text(t.common.retry)),
        ],
      ),
    );
  }
}
