import 'package:core/src/config/app_config.dart';
import 'package:core/src/logging/app_logger.dart';
import 'package:core/src/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'core_providers.g.dart';

/// Configuración de la app (token TMDB, URLs) desde el entorno de compilación.
@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) => AppConfig.fromEnvironment();

/// Instancia única de Talker: logger de la app, interceptor de Dio y observer
/// de Riverpod comparten esta misma instancia.
@Riverpod(keepAlive: true)
Talker talker(Ref ref) => TalkerFlutter.init();

/// Fachada de logging de la app.
@Riverpod(keepAlive: true)
AppLogger appLogger(Ref ref) => AppLogger(ref.watch(talkerProvider));

/// Cliente Dio configurado con auth Bearer e interceptor de logs de Talker.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final config = ref.watch(appConfigProvider);
  final talkerLogger = ref.watch(talkerProvider);

  return Dio(
    BaseOptions(
      baseUrl: config.tmdbBaseUrl,
      headers: {
        'Authorization': 'Bearer ${config.tmdbAccessToken}',
        'accept': 'application/json',
      },
    ),
  )..interceptors.add(TalkerDioLogger(talker: talkerLogger));
}

/// Cliente HTTP tipado para consumir TMDB.
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) => ApiClient(ref.watch(dioProvider));
