/// API pública de la feature de catálogo: entidades de dominio, contrato del
/// repositorio, su provider (para overrides en bootstrap) y las páginas.
/// Los DTOs, datasources e implementaciones quedan como detalle interno.
library;

export 'src/data/providers/catalog_data_providers.dart'
    show catalogRepositoryProvider;
export 'src/domain/entities/media.dart';
export 'src/domain/entities/media_detail.dart';
export 'src/domain/repositories/catalog_repository.dart';
export 'src/presentation/browse/widgets/catalog_home_page.dart';
export 'src/presentation/detail/widgets/media_detail_page.dart';
export 'src/presentation/search/widgets/search_page.dart';
