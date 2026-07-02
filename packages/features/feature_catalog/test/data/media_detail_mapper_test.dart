import 'package:feature_catalog/src/data/dtos/media_detail_dto.dart';
import 'package:feature_catalog/src/data/mappers/media_detail_mapper.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MediaDetailDtoMapper', () {
    test('given a movie detail dto, then maps genres, runtime and cast', () {
      const dto = MediaDetailDto(
        id: 550,
        title: 'Fight Club',
        runtime: 139,
        genres: [GenreDto(id: 18, name: 'Drama')],
        credits: CreditsDto(
          cast: [
            CastMemberDto(
              id: 819,
              name: 'Edward Norton',
              character: 'Narrator',
            ),
          ],
        ),
      );

      final detail = dto.toDomain(MediaType.movie);

      expect(detail.runtime, 139);
      expect(detail.genres.single.name, 'Drama');
      expect(detail.cast.single.character, 'Narrator');
    });

    test('given a tv detail dto, then runtime comes from episode_run_time', () {
      const dto = MediaDetailDto(id: 1, name: 'From', episodeRunTime: [50]);

      final detail = dto.toDomain(MediaType.tv);

      expect(detail.type, MediaType.tv);
      expect(detail.title, 'From');
      expect(detail.runtime, 50);
    });
  });
}
