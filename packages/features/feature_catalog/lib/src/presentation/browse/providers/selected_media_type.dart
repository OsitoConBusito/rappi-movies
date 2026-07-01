import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_media_type.g.dart';

/// Tipo de contenido activo en el catálogo (toggle Movies/Series).
@riverpod
class SelectedMediaType extends _$SelectedMediaType {
  @override
  MediaType build() => MediaType.movie;

  // Método-comando idiomático de Riverpod; un setter no aplica a un Notifier.
  // ignore: use_setters_to_change_properties
  void select(MediaType type) => state = type;
}
