import 'package:core/core.dart';
import 'package:feature_catalog/src/data/dtos/media_page_dto.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';

/// Fuente de datos remota del catálogo (TMDB). Construye las rutas a partir del
/// tipo y la categoría, y delega el manejo de errores al [ApiClient].
class CatalogRemoteDataSource {
  const CatalogRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  // TODO(juan): derivar del locale del dispositivo con fallback en (RN-4, M6).
  static const String _language = 'es-MX';

  Future<Either<Failure, MediaPageDto>> getCategory({
    required MediaType type,
    required MediaCategory category,
    required int page,
  }) {
    final path = '/${_typeSegment(type)}/${_categorySegment(category)}';
    return _apiClient.get<MediaPageDto>(
      path,
      queryParameters: {'page': page, 'language': _language},
      decode: (data) => MediaPageDto.fromJson(data! as Map<String, dynamic>),
    );
  }

  String _typeSegment(MediaType type) => switch (type) {
    MediaType.movie => 'movie',
    MediaType.tv => 'tv',
  };

  String _categorySegment(MediaCategory category) => switch (category) {
    MediaCategory.popular => 'popular',
    MediaCategory.topRated => 'top_rated',
  };
}
