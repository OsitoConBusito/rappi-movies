import 'package:core/core.dart';
import 'package:feature_catalog/src/data/datasources/catalog_remote_data_source.dart';
import 'package:feature_catalog/src/data/repositories/catalog_repository_impl.dart';
import 'package:feature_catalog/src/domain/repositories/catalog_repository.dart';
import 'package:i18n/i18n.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalog_data_providers.g.dart';

/// Idioma de los datos de TMDB (RN-4): el languageCode del locale activo.
@riverpod
String tmdbLanguage(Ref ref) =>
    LocaleSettings.instance.currentLocale.languageCode;

@riverpod
CatalogRemoteDataSource catalogRemoteDataSource(Ref ref) =>
    CatalogRemoteDataSource(
      ref.watch(apiClientProvider),
      languageCode: ref.watch(tmdbLanguageProvider),
    );

/// Repositorio del catálogo. `keepAlive` para preservar la caché en memoria
/// entre pantallas mientras dura la sesión.
@Riverpod(keepAlive: true)
CatalogRepository catalogRepository(Ref ref) =>
    CatalogRepositoryImpl(ref.watch(catalogRemoteDataSourceProvider));
