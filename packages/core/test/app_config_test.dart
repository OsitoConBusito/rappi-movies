import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test(
      'given no dart-defines, when built from environment, '
      'then falls back to the default TMDB urls',
      () {
        final config = AppConfig.fromEnvironment();

        expect(config.tmdbBaseUrl, 'https://api.themoviedb.org/3');
        expect(config.tmdbImageBaseUrl, 'https://image.tmdb.org/t/p');
      },
    );

    test('given an empty token, when checking hasToken, then it is false', () {
      const config = AppConfig(
        tmdbAccessToken: '',
        tmdbBaseUrl: 'https://api.themoviedb.org/3',
        tmdbImageBaseUrl: 'https://image.tmdb.org/t/p',
      );

      expect(config.hasToken, isFalse);
    });
  });

  group('Failure', () {
    test('given a NetworkFailure, then it exposes a non-empty message', () {
      const failure = NetworkFailure();

      expect(failure, isA<Failure>());
      expect(failure.message, isNotEmpty);
    });
  });
}
