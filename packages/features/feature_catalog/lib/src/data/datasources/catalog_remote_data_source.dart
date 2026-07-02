import 'package:core/core.dart';
import 'package:feature_catalog/src/data/dtos/media_detail_dto.dart';
import 'package:feature_catalog/src/data/dtos/media_page_dto.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';

/// Fuente de datos remota del catálogo (TMDB). Construye las rutas a partir del
/// tipo y la categoría, y delega el manejo de errores al [ApiClient].
class CatalogRemoteDataSource {
  const CatalogRemoteDataSource(this._apiClient, {required this.languageCode});

  final ApiClient _apiClient;

  /// Idioma de los datos de TMDB (RN-4), derivado del locale activo.
  final String languageCode;

  Future<Either<Failure, MediaPageDto>> getCategory({
    required MediaType type,
    required MediaCategory category,
    required int page,
  }) {
    final path = '/${_typeSegment(type)}/${_categorySegment(category)}';
    return _apiClient.get<MediaPageDto>(
      path,
      queryParameters: {'page': page, 'language': languageCode},
      decode: (data) => MediaPageDto.fromJson(data! as Map<String, dynamic>),
    );
  }

  Future<Either<Failure, MediaDetailDto>> getDetail({
    required MediaType type,
    required int id,
  }) {
    return _apiClient.get<MediaDetailDto>(
      '/${_typeSegment(type)}/$id',
      queryParameters: {
        'language': languageCode,
        'append_to_response': 'credits',
      },
      decode: (data) => MediaDetailDto.fromJson(data! as Map<String, dynamic>),
    );
  }

  Future<Either<Failure, MediaPageDto>> search(String query) {
    return _apiClient.get<MediaPageDto>(
      '/search/multi',
      queryParameters: {
        'query': query,
        'language': languageCode,
        'include_adult': false,
      },
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
