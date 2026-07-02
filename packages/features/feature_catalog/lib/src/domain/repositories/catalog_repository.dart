import 'package:core/core.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:feature_catalog/src/domain/entities/media_detail.dart';

/// Contrato de acceso al catálogo, diseñado **reactivo** (single-source-of-
/// truth): [watchCategory] emite la lista desde la caché local y
/// [refreshCategory] pide a la red y actualiza esa caché, disparando una nueva
/// emisión.
///
/// En M1 la implementación es remote-only sobre una caché en memoria; en M4 la
/// respalda Drift sin cambiar este contrato, por lo que el swap a offline-first
/// queda localizado en la capa de datos.
abstract interface class CatalogRepository {
  /// Emite la lista cacheada de una categoría y re-emite cuando la red la
  /// actualiza.
  Stream<Either<Failure, List<Media>>> watchCategory({
    required MediaType type,
    required MediaCategory category,
  });

  /// Pide la [page] de una categoría a la red y actualiza la caché. Devuelve
  /// `true` si existen más páginas por cargar.
  Future<Either<Failure, bool>> refreshCategory({
    required MediaType type,
    required MediaCategory category,
    required int page,
  });

  /// Devuelve el detalle de un título (desde la caché si ya se cargó antes).
  Future<Either<Failure, MediaDetail>> getDetail({
    required MediaType type,
    required int id,
  });
}
