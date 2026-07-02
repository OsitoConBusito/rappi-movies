import 'package:flutter_test/flutter_test.dart';
import 'package:i18n/i18n.dart';

void main() {
  group('Translations', () {
    test('given the es locale (base), then strings are in Spanish', () async {
      final t = await AppLocale.es.build();

      expect(t.catalog.movies, 'Películas');
      expect(t.common.retry, 'Reintentar');
    });

    test('given the en locale, then strings are in English', () async {
      final t = await AppLocale.en.build();

      expect(t.catalog.movies, 'Movies');
      expect(t.common.retry, 'Retry');
    });
  });
}
