import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/ingredient_catalog_entry.dart';
import '../repositories/ingredient_catalog_repository.dart';
import 'repository_providers.dart';

part 'ingredient_catalog_provider.g.dart';

@Riverpod(keepAlive: true)
class IngredientCatalog extends _$IngredientCatalog {
  late IngredientCatalogRepository _repo;

  @override
  Future<List<IngredientCatalogEntry>> build() async {
    _repo = await ref.watch(ingredientCatalogRepositoryProvider.future);
    return _repo.readAll();
  }

  /// Upsert an entry. If an entry with the same id exists, it is updated.
  Future<void> upsert(IngredientCatalogEntry entry) async {
    await _repo.upsertEntry(entry);
    state = AsyncData(await _repo.readAll());
  }

  /// Convenience: upsert from raw ingredient data (name, unit, category).
  Future<void> learnIngredient({
    required String name,
    required String unit,
    required String category,
  }) async {
    if (name.trim().isEmpty) return;
    final entry = IngredientCatalogEntry(
      id: name.trim().toLowerCase(),
      name: name.trim(),
      defaultUnit: unit.trim(),
      defaultCategory: category.trim(),
    );
    await upsert(entry);
  }

  /// Find matching entries for autocomplete.
  List<IngredientCatalogEntry> search(String query) {
    final entries = state.valueOrNull ?? [];
    if (query.trim().isEmpty) return entries;
    final lower = query.trim().toLowerCase();
    return entries
        .where((e) => e.name.toLowerCase().contains(lower))
        .toList();
  }
}
