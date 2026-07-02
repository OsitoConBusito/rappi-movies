import 'package:core/src/connectivity/connection_status.dart';
import 'package:core/src/connectivity/connectivity_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_providers.g.dart';

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) => ConnectivityService();

/// Estado de conexión real de la app, consumible por la UI (banner offline).
@riverpod
Stream<ConnectionStatus> connectionStatus(Ref ref) =>
    ref.watch(connectivityServiceProvider).statusStream;
