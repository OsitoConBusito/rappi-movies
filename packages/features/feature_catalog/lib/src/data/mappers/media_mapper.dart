import 'package:feature_catalog/src/data/dtos/media_dto.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';

/// Traduce un [MediaDto] al modelo de dominio [Media], resolviendo las
/// diferencias de TMDB entre película (`title`/`release_date`) y serie
/// (`name`/`first_air_date`) según el tipo (movie/tv) del endpoint consultado.
extension MediaDtoMapper on MediaDto {
  Media toDomain(MediaType type) {
    final rawDate = type == MediaType.movie ? releaseDate : firstAirDate;
    return Media(
      id: id,
      type: type,
      title: (title ?? name ?? '').trim(),
      overview: overview ?? '',
      voteAverage: voteAverage,
      genreIds: genreIds,
      posterPath: posterPath,
      backdropPath: backdropPath,
      releaseDate: _parseDate(rawDate),
    );
  }
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}
