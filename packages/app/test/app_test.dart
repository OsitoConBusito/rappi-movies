import 'package:app/src/app.dart';
import 'package:core/core.dart';
import 'package:feature_catalog/feature_catalog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCatalogRepository implements CatalogRepository {
  @override
  Stream<Either<Failure, List<Media>>> watchCategory({
    required MediaType type,
    required MediaCategory category,
  }) async* {
    yield Right<Failure, List<Media>>([
      Media(
        id: 1,
        type: type,
        title: 'Nightfall',
        overview: '',
        voteAverage: 8,
        genreIds: const [],
      ),
    ]);
  }

  @override
  Future<Either<Failure, bool>> refreshCategory({
    required MediaType type,
    required MediaCategory category,
    required int page,
  }) async => const Right(false);
}

void main() {
  testWidgets(
    'given the app, when it starts, then it renders the catalog home shell',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            catalogRepositoryProvider.overrideWithValue(
              _FakeCatalogRepository(),
            ),
          ],
          child: const MarqueeApp(),
        ),
      );

      expect(find.text('MARQUEE'), findsOneWidget);
      expect(find.text('Popular'), findsOneWidget);
      expect(find.text('Top Rated'), findsOneWidget);
    },
  );
}
