import 'package:core/core.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_section_state.freezed.dart';

/// Estado de carga de una sección del catálogo, mapeable directo a los estados
/// de UI del spec (§6): loading / data / error.
enum SectionStatus { loading, data, error }

/// Estado de una sección (una categoría de un tipo) del catálogo, incluyendo la
/// paginación (scroll infinito) y el sub-estado de "cargando más".
@freezed
abstract class CatalogSectionState with _$CatalogSectionState {
  const factory CatalogSectionState({
    @Default(SectionStatus.loading) SectionStatus status,
    @Default(<Media>[]) List<Media> items,
    @Default(0) int page,
    @Default(true) bool hasMore,
    @Default(false) bool isLoadingMore,
    Failure? failure,
  }) = _CatalogSectionState;

  const CatalogSectionState._();

  bool get isInitialLoading => status == SectionStatus.loading;
  bool get hasError => status == SectionStatus.error;
}
