import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:feature_catalog/src/presentation/browse/providers/catalog_section_notifier.dart';
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
///
/// En tablet/desktop los grids no tienen scroll propio (van dentro del
/// [ListView] de la página), así que la paginación por scroll infinito la
/// dispara la propia página sobre la última sección.
class CatalogHomePage extends ConsumerStatefulWidget {
  const CatalogHomePage({this.onOpenMedia, super.key});

  /// Callback al seleccionar un título; lo cablea el router del app-shell.
  final void Function(Media media)? onOpenMedia;

  @override
  ConsumerState<CatalogHomePage> createState() => _CatalogHomePageState();
}

class _CatalogHomePageState extends ConsumerState<CatalogHomePage> {
  static const double _loadMoreThreshold = 600;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isMobile =
        AppBreakpoints.of(MediaQuery.sizeOf(context).width) ==
        DeviceClass.mobile;
    // En móvil cada carrusel pagina por su propio scroll horizontal.
    if (isMobile) return;

    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - _loadMoreThreshold) return;

    final type = ref.read(selectedMediaTypeProvider);
    unawaited(
      ref
          .read(catalogSectionProvider(type, MediaCategory.topRated).notifier)
          .loadMore(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          controller: _scrollController,
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
              child: FeaturedHero(type: type, onOpen: widget.onOpenMedia),
            ),
            const SizedBox(height: AppSpacing.xl),
            CatalogSectionView(
              type: type,
              category: MediaCategory.popular,
              title: t.catalog.popular,
              onOpen: widget.onOpenMedia,
            ),
            const SizedBox(height: AppSpacing.xl),
            CatalogSectionView(
              type: type,
              category: MediaCategory.topRated,
              title: t.catalog.topRated,
              onOpen: widget.onOpenMedia,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
