import 'dart:convert';

import 'package:core/core.dart';
import 'package:feature_catalog/src/data/datasources/catalog_remote_data_source.dart';
import 'package:feature_catalog/src/data/dtos/media_detail_dto.dart';
import 'package:feature_catalog/src/data/local/catalog_database.dart';
import 'package:feature_catalog/src/data/mappers/drift_mappers.dart';
import 'package:feature_catalog/src/data/mappers/media_detail_mapper.dart';
import 'package:feature_catalog/src/data/mappers/media_mapper.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:feature_catalog/src/domain/entities/media_detail.dart';
import 'package:feature_catalog/src/domain/repositories/catalog_repository.dart';

/// Implementación **offline-first** del catálogo: la caché local (Drift) es la
/// única fuente de verdad. `watchCategory` emite desde Drift (reactivo) y
/// `refreshCategory` pide a la red y actualiza la caché, que dispara la nueva
/// emisión. Sin conexión, se sigue sirviendo lo cacheado.
class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._remote, this._db);

  final CatalogRemoteDataSource _remote;
  final CatalogDatabase _db;

  @override
  Stream<Either<Failure, List<Media>>> watchCategory({
    required MediaType type,
    required MediaCategory category,
  }) {
    return _db
        .watchCategory(type.name, category.name)
        .map<Either<Failure, List<Media>>>(
          (rows) => Right(rows.map((row) => row.toDomain()).toList()),
        );
  }

  @override
  Future<Either<Failure, bool>> refreshCategory({
    required MediaType type,
    required MediaCategory category,
    required int page,
  }) async {
    final result = await _remote.getCategory(
      type: type,
      category: category,
      page: page,
    );
    return result.match(
      (failure) async => Left(failure),
      (pageDto) async {
        final entries = pageDto.results
            .map((dto) => dto.toDomain(type).toCompanion())
            .toList();
        await _db.saveCategoryPage(
          type: type.name,
          category: category.name,
          page: page,
          entries: entries,
        );
        return Right(pageDto.page < pageDto.totalPages);
      },
    );
  }

  @override
  Future<Either<Failure, MediaDetail>> getDetail({
    required MediaType type,
    required int id,
  }) async {
    final result = await _remote.getDetail(type: type, id: id);
    return result.match(
      (failure) async {
        // Offline: servir el detalle desde la caché si existe.
        final payload = await _db.getDetailPayload(type.name, id);
        if (payload == null) return Left(failure);
        final dto = MediaDetailDto.fromJson(
          jsonDecode(payload) as Map<String, dynamic>,
        );
        return Right(dto.toDomain(type));
      },
      (dto) async {
        await _db.saveDetailPayload(type.name, id, jsonEncode(dto.toJson()));
        return Right(dto.toDomain(type));
      },
    );
  }

  @override
  Future<Either<Failure, List<Media>>> search(String query) async {
    if (query.trim().isEmpty) return const Right([]);

    final result = await _remote.search(query.trim());
    return result.map((page) {
      final medias = <Media>[];
      for (final dto in page.results) {
        final type = dto.searchType();
        if (type != null) medias.add(dto.toDomain(type));
      }
      return medias;
    });
  }
}
