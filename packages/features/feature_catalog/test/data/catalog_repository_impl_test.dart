import 'package:core/core.dart';
import 'package:feature_catalog/src/data/datasources/catalog_remote_data_source.dart';
import 'package:feature_catalog/src/data/dtos/media_dto.dart';
import 'package:feature_catalog/src/data/dtos/media_page_dto.dart';
import 'package:feature_catalog/src/data/repositories/catalog_repository_impl.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements CatalogRemoteDataSource {}

MediaPageDto _page(int page, int totalPages, List<int> ids) => MediaPageDto(
  page: page,
  totalPages: totalPages,
  results: [for (final id in ids) MediaDto(id: id, title: 'T$id')],
);

void main() {
  late _MockRemote remote;
  late CatalogRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = CatalogRepositoryImpl(remote);
  });

  group('CatalogRepositoryImpl', () {
    test(
      'given a successful first page, then watchCategory emits the mapped '
      'list and hasMore is true',
      () async {
        when(
          () => remote.getCategory(
            type: MediaType.movie,
            category: MediaCategory.popular,
            page: 1,
          ),
        ).thenAnswer(
          (_) async => Right<Failure, MediaPageDto>(_page(1, 3, [1, 2])),
        );

        final emissions = <List<Media>>[];
        final sub = repository
            .watchCategory(
              type: MediaType.movie,
              category: MediaCategory.popular,
            )
            .listen((either) => either.match((_) {}, emissions.add));

        final result = await repository.refreshCategory(
          type: MediaType.movie,
          category: MediaCategory.popular,
          page: 1,
        );
        await Future<void>.delayed(Duration.zero);

        expect(result.getOrElse((_) => false), isTrue);
        expect(emissions.last.map((m) => m.id).toList(), [1, 2]);
        await sub.cancel();
      },
    );

    test('given a second page, then items accumulate in the cache', () async {
      when(
        () => remote.getCategory(
          type: MediaType.movie,
          category: MediaCategory.popular,
          page: any(named: 'page'),
        ),
      ).thenAnswer((invocation) async {
        final page = invocation.namedArguments[#page] as int;
        return Right<Failure, MediaPageDto>(
          _page(page, 2, page == 1 ? [1, 2] : [3, 4]),
        );
      });

      await repository.refreshCategory(
        type: MediaType.movie,
        category: MediaCategory.popular,
        page: 1,
      );
      final second = await repository.refreshCategory(
        type: MediaType.movie,
        category: MediaCategory.popular,
        page: 2,
      );

      final emissions = <List<Media>>[];
      final sub = repository
          .watchCategory(type: MediaType.movie, category: MediaCategory.popular)
          .listen((either) => either.match((_) {}, emissions.add));
      await Future<void>.delayed(Duration.zero);

      expect(second.getOrElse((_) => true), isFalse);
      expect(emissions.last.map((m) => m.id).toList(), [1, 2, 3, 4]);
      await sub.cancel();
    });

    test('given a failure with no cache, then refresh returns Left', () async {
      when(
        () => remote.getCategory(
          type: MediaType.tv,
          category: MediaCategory.topRated,
          page: 1,
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, MediaPageDto>(NetworkFailure()),
      );

      final result = await repository.refreshCategory(
        type: MediaType.tv,
        category: MediaCategory.topRated,
        page: 1,
      );

      expect(result.isLeft(), isTrue);
    });
  });
}
