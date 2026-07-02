import 'dart:async';

import 'package:core/core.dart';
import 'package:feature_catalog/src/data/datasources/catalog_remote_data_source.dart';
import 'package:feature_catalog/src/data/mappers/media_detail_mapper.dart';
import 'package:feature_catalog/src/data/mappers/media_mapper.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:feature_catalog/src/domain/entities/media_detail.dart';
import 'package:feature_catalog/src/domain/repositories/catalog_repository.dart';

/// Implementación remote-only del catálogo con una **caché reactiva en
/// memoria**: `watchCategory` emite la lista acumulada y `refreshCategory`
/// pide a la red, acumula páginas y re-emite. En M4 esta caché se reemplaza por
/// Drift (single-source-of-truth persistente) sin tocar el contrato de dominio.
class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._remote);

  final CatalogRemoteDataSource _remote;

  final Map<String, List<Media>> _cache = {};
  final Map<String, StreamController<Either<Failure, List<Media>>>>
  _controllers = {};
  final Map<String, MediaDetail> _detailCache = {};

  String _keyOf(MediaType type, MediaCategory category) =>
      '${type.name}_${category.name}';

  StreamController<Either<Failure, List<Media>>> _controllerFor(String key) =>
      _controllers.putIfAbsent(
        key,
        StreamController<Either<Failure, List<Media>>>.broadcast,
      );

  @override
  Stream<Either<Failure, List<Media>>> watchCategory({
    required MediaType type,
    required MediaCategory category,
  }) async* {
    final key = _keyOf(type, category);
    final controller = _controllerFor(key);
    final cached = _cache[key];
    if (cached != null) {
      yield Right(cached);
    }
    yield* controller.stream;
  }

  @override
  Future<Either<Failure, bool>> refreshCategory({
    required MediaType type,
    required MediaCategory category,
    required int page,
  }) async {
    final key = _keyOf(type, category);
    final result = await _remote.getCategory(
      type: type,
      category: category,
      page: page,
    );

    return result.match(
      (failure) {
        // Offline-first: si ya hay caché, no la pisamos con el error; solo
        // propagamos el fallo por el stream cuando no hay nada que mostrar.
        if (!_cache.containsKey(key)) {
          _controllerFor(key).add(Left(failure));
        }
        return Left(failure);
      },
      (pageDto) {
        final fetched = pageDto.results
            .map((dto) => dto.toDomain(type))
            .toList();
        final previous = page == 1 ? <Media>[] : (_cache[key] ?? <Media>[]);
        final merged = [...previous, ...fetched];
        _cache[key] = merged;
        _controllerFor(key).add(Right(merged));
        return Right(pageDto.page < pageDto.totalPages);
      },
    );
  }

  @override
  Future<Either<Failure, MediaDetail>> getDetail({
    required MediaType type,
    required int id,
  }) async {
    final key = '${type.name}_$id';
    final cached = _detailCache[key];
    if (cached != null) return Right(cached);

    final result = await _remote.getDetail(type: type, id: id);
    return result.map((dto) {
      final detail = dto.toDomain(type);
      _detailCache[key] = detail;
      return detail;
    });
  }
}
