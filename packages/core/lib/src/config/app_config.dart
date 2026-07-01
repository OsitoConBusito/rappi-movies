/// Configuración de la app inyectada en tiempo de compilación mediante
/// `--dart-define-from-file`. El token de TMDB nunca se hardcodea ni commitea.
class AppConfig {
  const AppConfig({
    required this.tmdbAccessToken,
    required this.tmdbBaseUrl,
    required this.tmdbImageBaseUrl,
  });

  /// Lee las variables de entorno de compilación (ver `env/tmdb.json`).
  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      tmdbAccessToken: String.fromEnvironment('TMDB_ACCESS_TOKEN'),
      tmdbBaseUrl: String.fromEnvironment(
        'TMDB_BASE_URL',
        defaultValue: 'https://api.themoviedb.org/3',
      ),
      tmdbImageBaseUrl: String.fromEnvironment(
        'TMDB_IMAGE_BASE_URL',
        defaultValue: 'https://image.tmdb.org/t/p',
      ),
    );
  }

  /// TMDB API Read Access Token (v4), usado como `Bearer`.
  final String tmdbAccessToken;

  /// Base URL de la API v3 de TMDB.
  final String tmdbBaseUrl;

  /// Base URL para construir las URLs de imágenes (posters, backdrops).
  final String tmdbImageBaseUrl;

  /// Indica si hay un token configurado; útil para fallar temprano y claro.
  bool get hasToken => tmdbAccessToken.isNotEmpty;
}
