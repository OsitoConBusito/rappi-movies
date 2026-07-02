import 'package:design_system/design_system.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:feature_catalog/src/presentation/browse/providers/selected_media_type.dart';
import 'package:feature_catalog/src/presentation/browse/widgets/catalog_carousel.dart';
import 'package:feature_catalog/src/presentation/browse/widgets/language_selector.dart';
import 'package:feature_catalog/src/presentation/browse/widgets/media_type_toggle.dart';
import 'package:feature_catalog/src/presentation/browse/widgets/theme_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

/// Pantalla principal del catálogo (HU-1): toggle Movies/Series y las secciones
/// Popular y Top Rated como carruseles del tipo seleccionado.
class CatalogHomePage extends ConsumerWidget {
  const CatalogHomePage({this.onOpenMedia, super.key});

  /// Callback al seleccionar un título; lo cablea el router del app-shell.
  final void Function(Media media)? onOpenMedia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(selectedMediaTypeProvider);
    final textTheme = Theme.of(context).textTheme;
    final t = context.t;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MARQUEE', style: textTheme.headlineMedium),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [ThemeToggle(), LanguageSelector()],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Align(
                alignment: Alignment.centerLeft,
                child: MediaTypeToggle(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            CatalogCarousel(
              type: type,
              category: MediaCategory.popular,
              title: t.catalog.popular,
              onOpen: onOpenMedia,
            ),
            const SizedBox(height: AppSpacing.xl),
            CatalogCarousel(
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
