/// API pública del paquete `core`: services transversales (networking,
/// logging, configuración) y tipos de manejo de errores.
library;

export 'package:fpdart/fpdart.dart' show Either, Left, Right, Unit, unit;

export 'src/config/app_config.dart';
export 'src/connectivity/connection_status.dart';
export 'src/connectivity/connectivity_providers.dart';
export 'src/connectivity/connectivity_service.dart';
export 'src/core_providers.dart';
export 'src/error/failure.dart';
export 'src/logging/app_logger.dart';
export 'src/network/api_client.dart';
