import '../models/ingredient_catalog_entry.dart';
import 'json_file_repository.dart';

class IngredientCatalogRepository
    extends JsonFileRepository<IngredientCatalogEntry> {
  IngredientCatalogRepository({required super.storage})
      : super(fileName: 'ingredient_catalog.json');

  @override
  IngredientCatalogEntry fromJson(Map<String, dynamic> json) =>
      IngredientCatalogEntry.fromJson(json);

  @override
  Map<String, dynamic> toJson(IngredientCatalogEntry item) => item.toJson();

  Future<void> upsertEntry(IngredientCatalogEntry entry) =>
      upsert(entry, (e) => e.id);

  Future<bool> deleteEntry(String id) => deleteById(id, (e) => e.id);
}
