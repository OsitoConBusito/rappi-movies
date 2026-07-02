import 'package:core/core.dart';
import 'package:i18n/i18n.dart';

/// Traduce un [Failure] de dominio a un mensaje localizado. El dominio conserva
/// un mensaje en español como fallback de log; la UI muestra esta versión i18n.
extension FailureL10n on Failure {
  String localized(Translations t) => switch (this) {
    NetworkFailure() => t.errors.network,
    NotFoundFailure() => t.errors.notFound,
    ServerFailure() => t.errors.server,
    CacheFailure() => t.errors.cache,
    UnknownFailure() => t.errors.unknown,
  };
}
