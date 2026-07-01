import 'package:feature_catalog/src/data/dtos/media_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_page_dto.freezed.dart';
part 'media_page_dto.g.dart';

/// Respuesta paginada de TMDB para los listados de catálogo.
@freezed
abstract class MediaPageDto with _$MediaPageDto {
  const factory MediaPageDto({
    required int page,
    @Default(<MediaDto>[]) List<MediaDto> results,
    @JsonKey(name: 'total_pages') @Default(1) int totalPages,
  }) = _MediaPageDto;

  factory MediaPageDto.fromJson(Map<String, dynamic> json) =>
      _$MediaPageDtoFromJson(json);
}
