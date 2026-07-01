import 'package:talker_flutter/talker_flutter.dart';

/// Fachada de logging sobre Talker. Es la única puerta de logs de la app: el
/// resto del código nunca usa `print`. La misma instancia de [Talker] alimenta
/// el interceptor de Dio, el observer de Riverpod y la UI de logs en debug.
class AppLogger {
  const AppLogger(this.talker);

  /// Instancia subyacente de Talker.
  final Talker talker;

  /// Registra información de flujo normal.
  void info(String message) => talker.info(message);

  /// Registra una advertencia recuperable.
  void warning(String message) => talker.warning(message);

  /// Registra un error con su stack trace opcional.
  void error(Object error, [StackTrace? stackTrace]) =>
      talker.handle(error, stackTrace);
}
