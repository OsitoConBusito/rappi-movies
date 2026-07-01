import 'package:core/src/error/failure.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

/// Cliente HTTP tipado sobre Dio. Traduce los errores de red a [Failure], de
/// modo que las capas superiores reciben rutas de fallo explícitas en vez de
/// excepciones de infraestructura.
class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  /// GET que decodifica la respuesta con [decode] y devuelve un [Either].
  ///
  /// [decode] recibe el `data` crudo del response y lo transforma en `T`
  /// (normalmente un DTO). Cualquier fallo se mapea a un [Failure].
  Future<Either<Failure, T>> get<T>(
    String path, {
    required T Function(Object? data) decode,
    Map<String, Object?>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
      );
      return Right(decode(response.data));
    } on DioException catch (error) {
      return Left(_mapError(error));
    } on Object catch (error) {
      return Left(UnknownFailure(error.toString()));
    }
  }

  Failure _mapError(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 404) return const NotFoundFailure();
    if (statusCode != null && statusCode >= 500) return const ServerFailure();

    return switch (error.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const NetworkFailure(),
      _ => UnknownFailure(error.message ?? 'Error de red desconocido.'),
    };
  }
}
