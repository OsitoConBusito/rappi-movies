import 'package:feature_catalog/src/data/dtos/media_dto.dart';
import 'package:feature_catalog/src/data/mappers/media_mapper.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MediaDtoMapper', () {
    test('given a movie dto, then it maps title and release_date', () {
      const dto = MediaDto(
        id: 1,
        title: 'Nightfall',
        releaseDate: '2025-01-10',
        voteAverage: 8.4,
        genreIds: [18],
      );

      final media = dto.toDomain(MediaType.movie);

      expect(media.type, MediaType.movie);
      expect(media.title, 'Nightfall');
      expect(media.releaseDate, DateTime(2025, 1, 10));
    });

    test('given a tv dto, then it maps name and first_air_date', () {
      const dto = MediaDto(
        id: 2,
        name: 'From',
        firstAirDate: '2022-02-20',
        voteAverage: 8.5,
        genreIds: [9648],
      );

      final media = dto.toDomain(MediaType.tv);

      expect(media.type, MediaType.tv);
      expect(media.title, 'From');
      expect(media.releaseDate, DateTime(2022, 2, 20));
    });

    test('given an empty date, then releaseDate is null', () {
      const dto = MediaDto(id: 3, title: 'X', releaseDate: '');

      expect(dto.toDomain(MediaType.movie).releaseDate, isNull);
    });
  });
}
