import 'package:core/src/connectivity/connection_status.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Detección de conectividad que distingue "hay red" de "hay internet"
/// (ADR-0007). `internet_connection_checker_plus` reacciona a los cambios de
/// interfaz (vía `connectivity_plus`) y confirma alcanzabilidad real a hosts
/// fiables, evitando el falso positivo de "wifi sin salida".
class ConnectivityService {
  ConnectivityService({InternetConnection? checker})
    : _checker = checker ?? InternetConnection();

  final InternetConnection _checker;

  /// Emite el estado de conexión real cada vez que cambia.
  Stream<ConnectionStatus> get statusStream =>
      _checker.onStatusChange.map(_map);

  /// Estado actual (una comprobación puntual).
  Future<ConnectionStatus> current() async => _checker.hasInternetAccess.then(
    (hasAccess) =>
        hasAccess ? ConnectionStatus.online : ConnectionStatus.offline,
  );

  ConnectionStatus _map(InternetStatus status) =>
      status == InternetStatus.connected
      ? ConnectionStatus.online
      : ConnectionStatus.offline;
}
