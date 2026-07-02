import 'package:design_system/design_system.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:feature_catalog/src/presentation/browse/providers/selected_media_type.dart';
import 'package:feature_catalog/src/presentation/browse/widgets/catalog_section_view.dart';
import 'package:feature_catalog/src/presentation/browse/widgets/featured_hero.dart';
import 'package:feature_catalog/src/presentation/browse/widgets/media_type_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

/// Pantalla principal del catálogo (HU-1), **adaptativa**: toggle Movies/Series,
/// hero destacado, y las secciones Popular/Top Rated (carruseles en móvil,
/// grids en tablet/desktop).
class CatalogHomePage extends ConsumerWidget {
  const CatalogHomePage({this.onOpenMedia, super.key});

  /// Callback al seleccionar un título; lo cablea el router del app-shell.
  final void Function(Media media)? onOpenMedia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(selectedMediaTypeProvider);
    final textTheme = Theme.of(context).textTheme;
    final t = context.t;
    final isMobile =
        AppBreakpoints.of(MediaQuery.sizeOf(context).width) ==
        DeviceClass.mobile;
    final horizontalPadding = isMobile ? AppSpacing.lg : AppSpacing.xl;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMobile) ...[
                    Text('MARQUEE', style: textTheme.headlineMedium),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: MediaTypeToggle(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: FeaturedHero(type: type, onOpen: onOpenMedia),
            ),
            const SizedBox(height: AppSpacing.xl),
            CatalogSectionView(
              type: type,
              category: MediaCategory.popular,
              title: t.catalog.popular,
              onOpen: onOpenMedia,
            ),
            const SizedBox(height: AppSpacing.xl),
            CatalogSectionView(
              type: type,
              category: MediaCategory.topRated,
              title: t.catalog.topRated,
              onOpen: onOpenMedia,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
