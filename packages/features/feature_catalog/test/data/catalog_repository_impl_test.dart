import 'package:core/core.dart';
import 'package:drift/native.dart';
import 'package:feature_catalog/src/data/datasources/catalog_remote_data_source.dart';
import 'package:feature_catalog/src/data/dtos/media_dto.dart';
import 'package:feature_catalog/src/data/dtos/media_page_dto.dart';
import 'package:feature_catalog/src/data/local/catalog_database.dart';
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
  late CatalogDatabase db;
  late CatalogRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    db = CatalogDatabase.forTesting(NativeDatabase.memory());
    repository = CatalogRepositoryImpl(remote, db);
  });

  tearDown(() => db.close());

  Stream<List<int>> idsStream() => repository
      .watchCategory(type: MediaType.movie, category: MediaCategory.popular)
      .map(
        (either) =>
            either.getOrElse((_) => []).map((media) => media.id).toList(),
      );

  void stubPage(int page, MediaPageDto response) {
    when(
      () => remote.getCategory(
        type: MediaType.movie,
        category: MediaCategory.popular,
        page: page,
      ),
    ).thenAnswer((_) async => Right<Failure, MediaPageDto>(response));
  }

  group('CatalogRepositoryImpl (Drift SSOT)', () {
    test('given a refreshed first page, then watchCategory emits it', () async {
      stubPage(1, _page(1, 3, [1, 2]));

      await repository.refreshCategory(
        type: MediaType.movie,
        category: MediaCategory.popular,
        page: 1,
      );

      await expectLater(idsStream(), emits([1, 2]));
    });

    test('given a second page, then items accumulate in the cache', () async {
      stubPage(1, _page(1, 2, [1, 2]));
      stubPage(2, _page(2, 2, [3, 4]));

      await repository.refreshCategory(
        type: MediaType.movie,
        category: MediaCategory.popular,
        page: 1,
      );
      await repository.refreshCategory(
        type: MediaType.movie,
        category: MediaCategory.popular,
        page: 2,
      );

      await expectLater(idsStream(), emits([1, 2, 3, 4]));
    });

    test(
      'given no connection but a populated cache, then it keeps serving it',
      () async {
        stubPage(1, _page(1, 1, [1, 2]));
        await repository.refreshCategory(
          type: MediaType.movie,
          category: MediaCategory.popular,
          page: 1,
        );

        when(
          () => remote.getCategory(
            type: MediaType.movie,
            category: MediaCategory.popular,
            page: 1,
          ),
        ).thenAnswer(
          (_) async => const Left<Failure, MediaPageDto>(NetworkFailure()),
        );
        final result = await repository.refreshCategory(
          type: MediaType.movie,
          category: MediaCategory.popular,
          page: 1,
        );

        expect(result.isLeft(), isTrue);
        await expectLater(idsStream(), emits([1, 2]));
      },
    );
  });
}
