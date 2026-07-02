import 'package:core/core.dart';
import 'package:feature_catalog/src/data/datasources/catalog_remote_data_source.dart';
import 'package:feature_catalog/src/data/local/catalog_database.dart';
import 'package:feature_catalog/src/data/repositories/catalog_repository_impl.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:feature_catalog/src/domain/entities/media_detail.dart';
import 'package:feature_catalog/src/domain/repositories/catalog_repository.dart';
import 'package:i18n/i18n.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalog_data_providers.g.dart';

/// Idioma de los datos de TMDB (RN-4): el languageCode del locale activo.
/// Reactivo al selector de idioma — cambiar de idioma refresca el catálogo.
@riverpod
String tmdbLanguage(Ref ref) =>
    ref.watch(localeControllerProvider).languageCode;

@riverpod
CatalogRemoteDataSource catalogRemoteDataSource(Ref ref) =>
    CatalogRemoteDataSource(
      ref.watch(apiClientProvider),
      languageCode: ref.watch(tmdbLanguageProvider),
    );

/// Repositorio del catálogo. `keepAlive` para preservar la caché en memoria
/// entre pantallas mientras dura la sesión.
/// Base de datos local (Drift). Se cierra al desecharse el provider.
@Riverpod(keepAlive: true)
CatalogDatabase catalogDatabase(Ref ref) {
  final database = CatalogDatabase();
  ref.onDispose(database.close);
  return database;
}

@Riverpod(keepAlive: true)
CatalogRepository catalogRepository(Ref ref) => CatalogRepositoryImpl(
  ref.watch(catalogRemoteDataSourceProvider),
  ref.watch(catalogDatabaseProvider),
);

/// Detalle de un título. Los estados de carga/error se manejan con AsyncValue;
/// el fallo se propaga como error (Failure es Exception).
@riverpod
Future<MediaDetail> mediaDetail(Ref ref, MediaType type, int id) async {
  final result = await ref
      .watch(catalogRepositoryProvider)
      .getDetail(type: type, id: id);
  return result.fold((failure) => throw failure, (detail) => detail);
}
