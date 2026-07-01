import 'package:equatable/equatable.dart';

/// Tipo de contenido del catálogo (RN-2).
enum MediaType { movie, tv }

/// Categoría del catálogo soportada (RN-1).
enum MediaCategory { popular, topRated }

/// Título del catálogo (película o serie) unificado en un modelo genérico con
/// discriminador [type]. Representa el ítem de listado; el detalle enriquecido
/// es `MediaDetail`.
class Media extends Equatable {
  const Media({
    required this.id,
    required this.type,
    required this.title,
    required this.overview,
    required this.voteAverage,
    required this.genreIds,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
  });

  final int id;
  final MediaType type;
  final String title;
  final String overview;
  final double voteAverage;
  final List<int> genreIds;
  final String? posterPath;
  final String? backdropPath;
  final DateTime? releaseDate;

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    overview,
    voteAverage,
    genreIds,
    posterPath,
    backdropPath,
    releaseDate,
  ];
}
