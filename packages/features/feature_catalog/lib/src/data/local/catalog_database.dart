import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'catalog_database.g.dart';

/// Ítems del catálogo cacheados (película o serie), clave compuesta (id, type).
class MediaEntries extends Table {
  IntColumn get id => integer()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get overview => text()();
  RealColumn get voteAverage => real()();
  TextColumn get genreIds => text()(); // JSON: List<int>
  TextColumn get posterPath => text().nullable()();
  TextColumn get backdropPath => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id, type};
}

/// Membresía ordenada de un ítem en una categoría (para preservar el orden de
/// paginación al servir desde caché).
class CategoryItems extends Table {
  TextColumn get type => text()();
  TextColumn get category => text()();
  IntColumn get position => integer()();
  IntColumn get mediaId => integer()();

  @override
  Set<Column<Object>> get primaryKey => {type, category, position};
}

/// Detalle cacheado, guardado como JSON crudo de TMDB para servirse offline.
class MediaDetailEntries extends Table {
  IntColumn get id => integer()();
  TextColumn get type => text()();
  TextColumn get payload => text()();

  @override
  Set<Column<Object>> get primaryKey => {id, type};
}

/// Base de datos local (single-source-of-truth). En móvil y web (WASM) mediante
/// `drift_flutter`.
@DriftDatabase(tables: [MediaEntries, CategoryItems, MediaDetailEntries])
class CatalogDatabase extends _$CatalogDatabase {
  CatalogDatabase() : super(driftDatabase(name: 'catalog'));

  /// Constructor para tests (base en memoria).
  CatalogDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  /// Emite la lista de una categoría ordenada por posición; re-emite cuando la
  /// caché cambia.
  Stream<List<MediaEntry>> watchCategory(String type, String category) {
    final query =
        select(mediaEntries).join([
            innerJoin(
              categoryItems,
              categoryItems.mediaId.equalsExp(mediaEntries.id) &
                  categoryItems.type.equalsExp(mediaEntries.type),
            ),
          ])
          ..where(
            categoryItems.type.equals(type) &
                categoryItems.category.equals(category),
          )
          ..orderBy([OrderingTerm.asc(categoryItems.position)]);

    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(mediaEntries)).toList(),
    );
  }

  /// Guarda una página de una categoría: upsert de los ítems y de su orden.
  /// La página 1 reemplaza el orden previo; las siguientes lo extienden.
  Future<void> saveCategoryPage({
    required String type,
    required String category,
    required int page,
    required List<MediaEntriesCompanion> entries,
  }) {
    return transaction(() async {
      await batch((b) => b.insertAllOnConflictUpdate(mediaEntries, entries));

      if (page == 1) {
        await (delete(categoryItems)..where(
              (t) => t.type.equals(type) & t.category.equals(category),
            ))
            .go();
      }

      final countExp = categoryItems.mediaId.count();
      final countRow =
          await (selectOnly(categoryItems)
                ..addColumns([countExp])
                ..where(
                  categoryItems.type.equals(type) &
                      categoryItems.category.equals(category),
                ))
              .getSingle();
      var position = countRow.read(countExp) ?? 0;

      final items = [
        for (final entry in entries)
          CategoryItemsCompanion.insert(
            type: type,
            category: category,
            position: position++,
            mediaId: entry.id.value,
          ),
      ];
      await batch(
        (b) => b.insertAll(
          categoryItems,
          items,
          mode: InsertMode.insertOrReplace,
        ),
      );
    });
  }

  Future<String?> getDetailPayload(String type, int id) {
    return (select(mediaDetailEntries)
          ..where((t) => t.type.equals(type) & t.id.equals(id)))
        .map((row) => row.payload)
        .getSingleOrNull();
  }

  Future<void> saveDetailPayload(String type, int id, String payload) {
    return into(mediaDetailEntries).insertOnConflictUpdate(
      MediaDetailEntriesCompanion.insert(id: id, type: type, payload: payload),
    );
  }
}
