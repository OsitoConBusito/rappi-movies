import 'package:feature_catalog/src/data/dtos/media_detail_dto.dart';
import 'package:feature_catalog/src/data/mappers/media_mapper.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:feature_catalog/src/domain/entities/media_detail.dart';

/// Número máximo de miembros del reparto que se muestran en el detalle.
const _maxCastMembers = 15;

/// Traduce un [MediaDetailDto] al dominio [MediaDetail], resolviendo las
/// diferencias película/serie y la duración (movie: `runtime`; tv: primer
/// `episode_run_time`).
extension MediaDetailDtoMapper on MediaDetailDto {
  MediaDetail toDomain(MediaType type) {
    final rawDate = type == MediaType.movie ? releaseDate : firstAirDate;
    final resolvedRuntime =
        runtime ?? (episodeRunTime.isEmpty ? null : episodeRunTime.first);
    final resolvedTagline = (tagline ?? '').isEmpty ? null : tagline;

    return MediaDetail(
      id: id,
      type: type,
      title: (title ?? name ?? '').trim(),
      overview: overview ?? '',
      voteAverage: voteAverage,
      genreIds: genres.map((genre) => genre.id).toList(),
      genres: genres
          .map((genre) => Genre(id: genre.id, name: genre.name))
          .toList(),
      cast: (credits?.cast ?? [])
          .take(_maxCastMembers)
          .map(
            (member) => CastMember(
              id: member.id,
              name: member.name,
              character: member.character,
              profilePath: member.profilePath,
            ),
          )
          .toList(),
      posterPath: posterPath,
      backdropPath: backdropPath,
      releaseDate: parseTmdbDate(rawDate),
      runtime: resolvedRuntime,
      tagline: resolvedTagline,
      director: _directorOf(credits?.crew ?? const []),
      status: (status ?? '').isEmpty ? null : status,
      originalLanguage: originalLanguage,
      voteCount: voteCount,
      recommendations: (recommendations?.results ?? [])
          .where((dto) => dto.id != id)
          .map((dto) => dto.toDomain(type))
          .toList(),
    );
  }
}

String? _directorOf(List<CrewMemberDto> crew) {
  for (final member in crew) {
    if (member.job == 'Director') return member.name;
  }
  return null;
}
