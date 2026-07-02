import 'dart:async';

import 'package:feature_catalog/src/data/providers/catalog_data_providers.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:feature_catalog/src/presentation/browse/state/catalog_section_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalog_section_notifier.g.dart';

/// Orquesta una sección del catálogo (una [category] de un [type]): se suscribe
/// al stream reactivo del repositorio para los datos y dispara los refrescos de
/// red (primera página y paginación).
@riverpod
class CatalogSection extends _$CatalogSection {
  @override
  CatalogSectionState build(MediaType type, MediaCategory category) {
    final repository = ref.watch(catalogRepositoryProvider);

    final subscription = repository
        .watchCategory(type: type, category: category)
        .listen((result) {
          result.match(
            (failure) {
              if (state.items.isEmpty) {
                state = state.copyWith(
                  status: SectionStatus.error,
                  failure: failure,
                );
              }
            },
            (items) => state = state.copyWith(
              status: SectionStatus.data,
              items: items,
            ),
          );
        });
    ref.onDispose(subscription.cancel);

    unawaited(_refresh(page: 1));
    return const CatalogSectionState();
  }

  Future<void> _refresh({required int page}) async {
    if (page > 1) state = state.copyWith(isLoadingMore: true);

    final result = await ref
        .read(catalogRepositoryProvider)
        .refreshCategory(type: type, category: category, page: page);

    // El provider pudo disponerse durante el await (p. ej. al cambiar el
    // toggle Movies/Series); no escribas state sobre un Ref ya destruido.
    if (!ref.mounted) return;

    result.match(
      (failure) {
        state = state.items.isEmpty
            ? state.copyWith(status: SectionStatus.error, failure: failure)
            : state.copyWith(isLoadingMore: false);
      },
      (hasMore) => state = state.copyWith(
        page: page,
        hasMore: hasMore,
        isLoadingMore: false,
      ),
    );
  }

  /// Carga la siguiente página (scroll infinito). No hace nada si ya está
  /// cargando o no hay más páginas.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    await _refresh(page: state.page + 1);
  }

  /// Reintenta desde la primera página tras un error.
  Future<void> retry() async {
    state = const CatalogSectionState();
    await _refresh(page: 1);
  }
}
