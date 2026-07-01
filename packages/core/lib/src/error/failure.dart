/// Falla de dominio esperada. Las capas de datos traducen los errores de
/// infraestructura (Dio, Drift) a una de estas variantes, de modo que el
/// dominio y la presentación nunca vean una excepción de infraestructura.
sealed class Failure {
  const Failure(this.message);

  /// Mensaje accionable para logging o para mostrar en la UI.
  final String message;
}

/// Sin conexión o error de red al alcanzar TMDB.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet.']);
}

/// El recurso solicitado no existe (HTTP 404).
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado.']);
}

/// Error del lado del servidor de TMDB (HTTP 5xx).
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor de TMDB.']);
}

/// Error leyendo o escribiendo la caché local.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error leyendo la caché local.']);
}

/// Cualquier otra falla no clasificada.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Ocurrió un error inesperado.']);
}
