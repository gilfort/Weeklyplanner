import '../models/ingredient_catalog_entry.dart';
import '../sync/entity_merge.dart';
import 'entity_repository.dart';

class IngredientCatalogRepository
    extends EntityRepository<IngredientCatalogEntry> {
  IngredientCatalogRepository({required super.storage})
      : super(dirName: 'catalog');

  @override
  IngredientCatalogEntry fromJson(Map<String, dynamic> json) =>
      IngredientCatalogEntry.fromJson(json);

  @override
  Map<String, dynamic> toJson(IngredientCatalogEntry item) => item.toJson();

  @override
  String idOf(IngredientCatalogEntry item) => item.id;

  @override
  bool isDeleted(IngredientCatalogEntry item) => item.deleted;

  @override
  DateTime? deletedAtOf(IngredientCatalogEntry item) => item.deletedAt;

  @override
  IngredientCatalogEntry markDeleted(
    IngredientCatalogEntry item,
    DateTime at,
  ) =>
      item.copyWith(deleted: true, deletedAt: at);

  @override
  IngredientCatalogEntry merge(
    IngredientCatalogEntry base,
    IngredientCatalogEntry local,
    IngredientCatalogEntry remote, {
    required bool preferRemote,
  }) =>
      mergeCatalogEntry(base, local, remote, preferRemote: preferRemote);

  Future<void> upsertEntry(IngredientCatalogEntry entry) => upsert(entry);

  Future<bool> deleteEntry(String id) => delete(id);
}
