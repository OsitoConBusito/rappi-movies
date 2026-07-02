import 'dart:async';

import 'package:feature_catalog/src/data/providers/catalog_data_providers.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_controller.g.dart';

/// Filtro por tipo del buscador.
enum SearchFilter { all, movies, series }

/// Filtro activo del buscador.
@riverpod
class SelectedSearchFilter extends _$SelectedSearchFilter {
  @override
  SearchFilter build() => SearchFilter.all;

  // Método-comando idiomático de Riverpod; un setter no aplica a un Notifier.
  // ignore: use_setters_to_change_properties
  void select(SearchFilter filter) => state = filter;
}

/// Resultados de búsqueda combinada con **debounce** (RN-5: no se cachea; sin
/// conexión emite el fallo para mostrar el aviso).
@riverpod
class SearchResults extends _$SearchResults {
  static const _debounceDelay = Duration(milliseconds: 400);

  Timer? _debounce;

  @override
  FutureOr<List<Media>> build() {
    ref.onDispose(() => _debounce?.cancel());
    return const [];
  }

  void search(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = const AsyncData([]);
      return;
    }

    state = const AsyncLoading<List<Media>>();
    _debounce = Timer(_debounceDelay, () async {
      final result = await ref.read(catalogRepositoryProvider).search(trimmed);
      if (!ref.mounted) return;
      state = result.fold(
        (failure) => AsyncError(failure, StackTrace.current),
        AsyncData.new,
      );
    });
  }
}
