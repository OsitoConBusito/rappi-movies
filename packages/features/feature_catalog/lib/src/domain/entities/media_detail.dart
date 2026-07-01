import 'package:equatable/equatable.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';

/// Género de TMDB (id + nombre ya resuelto).
class Genre extends Equatable {
  const Genre({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// Miembro del reparto principal.
class CastMember extends Equatable {
  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  final int id;
  final String name;
  final String character;
  final String? profilePath;

  @override
  List<Object?> get props => [id, name, character, profilePath];
}

/// Detalle enriquecido de un título: extiende [Media] con géneros resueltos,
/// duración y reparto.
class MediaDetail extends Media {
  const MediaDetail({
    required super.id,
    required super.type,
    required super.title,
    required super.overview,
    required super.voteAverage,
    required super.genreIds,
    required this.genres,
    required this.cast,
    super.posterPath,
    super.backdropPath,
    super.releaseDate,
    this.runtime,
    this.tagline,
  });

  final List<Genre> genres;
  final List<CastMember> cast;
  final int? runtime;
  final String? tagline;

  @override
  List<Object?> get props => [...super.props, genres, cast, runtime, tagline];
}
