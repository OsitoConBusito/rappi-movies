import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_dto.freezed.dart';
part 'media_dto.g.dart';

/// DTO de un ítem de listado de TMDB. Un único DTO cubre película y serie: TMDB
/// usa `title`/`release_date` para movie y `name`/`first_air_date` para tv; el
/// mapper resuelve el modelo de dominio según el tipo (movie/tv) del endpoint.
@freezed
abstract class MediaDto with _$MediaDto {
  const factory MediaDto({
    required int id,
    String? title,
    String? name,
    String? overview,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    @JsonKey(name: 'vote_average') @Default(0.0) double voteAverage,
    @JsonKey(name: 'genre_ids') @Default(<int>[]) List<int> genreIds,
    @JsonKey(name: 'release_date') String? releaseDate,
    @JsonKey(name: 'first_air_date') String? firstAirDate,
    // Solo presente en /search/multi (movie|tv|person).
    @JsonKey(name: 'media_type') String? mediaType,
  }) = _MediaDto;

  factory MediaDto.fromJson(Map<String, dynamic> json) =>
      _$MediaDtoFromJson(json);
}
