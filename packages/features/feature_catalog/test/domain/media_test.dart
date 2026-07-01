import 'package:feature_catalog/feature_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Media', () {
    test('given two media with identical fields, then they are equal', () {
      const a = Media(
        id: 1,
        type: MediaType.movie,
        title: 'Nightfall',
        overview: 'o',
        voteAverage: 8.4,
        genreIds: [18, 53],
      );
      const b = Media(
        id: 1,
        type: MediaType.movie,
        title: 'Nightfall',
        overview: 'o',
        voteAverage: 8.4,
        genreIds: [18, 53],
      );

      expect(a, equals(b));
    });

    test('given media with a different id, then they are not equal', () {
      const a = Media(
        id: 1,
        type: MediaType.movie,
        title: 'X',
        overview: '',
        voteAverage: 0,
        genreIds: [],
      );
      const b = Media(
        id: 2,
        type: MediaType.movie,
        title: 'X',
        overview: '',
        voteAverage: 0,
        genreIds: [],
      );

      expect(a, isNot(equals(b)));
    });
  });

  group('MediaDetail', () {
    test('given a detail, then it is a Media and carries genres and cast', () {
      const detail = MediaDetail(
        id: 42,
        type: MediaType.tv,
        title: 'From',
        overview: '',
        voteAverage: 8.5,
        genreIds: [9648],
        genres: [Genre(id: 9648, name: 'Misterio')],
        cast: [CastMember(id: 1, name: 'A. Ferro', character: 'Mara')],
      );

      expect(detail, isA<Media>());
      expect(detail.genres, hasLength(1));
      expect(detail.cast.first.character, 'Mara');
    });
  });
}
