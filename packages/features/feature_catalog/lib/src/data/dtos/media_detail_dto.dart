import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_detail_dto.freezed.dart';
part 'media_detail_dto.g.dart';

/// DTO del detalle de un título (TMDB `/movie/{id}` o `/tv/{id}` con
/// `append_to_response=credits`). Cubre película y serie en un solo DTO.
@freezed
abstract class MediaDetailDto with _$MediaDetailDto {
  const factory MediaDetailDto({
    required int id,
    String? title,
    String? name,
    String? overview,
    String? tagline,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    @JsonKey(name: 'vote_average') @Default(0.0) double voteAverage,
    @Default(<GenreDto>[]) List<GenreDto> genres,
    @JsonKey(name: 'release_date') String? releaseDate,
    @JsonKey(name: 'first_air_date') String? firstAirDate,
    int? runtime,
    @JsonKey(name: 'episode_run_time')
    @Default(<int>[])
    List<int> episodeRunTime,
    CreditsDto? credits,
  }) = _MediaDetailDto;

  factory MediaDetailDto.fromJson(Map<String, dynamic> json) =>
      _$MediaDetailDtoFromJson(json);
}

@freezed
abstract class GenreDto with _$GenreDto {
  const factory GenreDto({required int id, @Default('') String name}) =
      _GenreDto;

  factory GenreDto.fromJson(Map<String, dynamic> json) =>
      _$GenreDtoFromJson(json);
}

@freezed
abstract class CreditsDto with _$CreditsDto {
  const factory CreditsDto({
    @Default(<CastMemberDto>[]) List<CastMemberDto> cast,
  }) = _CreditsDto;

  factory CreditsDto.fromJson(Map<String, dynamic> json) =>
      _$CreditsDtoFromJson(json);
}

@freezed
abstract class CastMemberDto with _$CastMemberDto {
  const factory CastMemberDto({
    required int id,
    @Default('') String name,
    @Default('') String character,
    @JsonKey(name: 'profile_path') String? profilePath,
  }) = _CastMemberDto;

  factory CastMemberDto.fromJson(Map<String, dynamic> json) =>
      _$CastMemberDtoFromJson(json);
}
