import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:feature_catalog/src/data/local/catalog_database.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';

/// Convierte una fila cacheada de Drift al dominio.
extension MediaEntryMapper on MediaEntry {
  Media toDomain() {
    return Media(
      id: id,
      type: type == MediaType.tv.name ? MediaType.tv : MediaType.movie,
      title: title,
      overview: overview,
      voteAverage: voteAverage,
      genreIds: (jsonDecode(genreIds) as List<dynamic>).cast<int>(),
      posterPath: posterPath,
      backdropPath: backdropPath,
      releaseDate: releaseDate,
    );
  }
}

/// Convierte un [Media] de dominio a un companion de inserción de Drift.
extension MediaToCompanion on Media {
  MediaEntriesCompanion toCompanion() {
    return MediaEntriesCompanion.insert(
      id: id,
      type: type.name,
      title: title,
      overview: overview,
      voteAverage: voteAverage,
      genreIds: jsonEncode(genreIds),
      posterPath: Value(posterPath),
      backdropPath: Value(backdropPath),
      releaseDate: Value(releaseDate),
    );
  }
}
