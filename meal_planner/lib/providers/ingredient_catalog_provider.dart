import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../models/ingredient_catalog_entry.dart';
import '../repositories/ingredient_catalog_repository.dart';
import 'repository_providers.dart';

part 'ingredient_catalog_provider.g.dart';

const _uuid = Uuid();

/// The catalog owns ingredient identity. Everything that refers to an
/// ingredient — recipe lines, general items, the week's checked-off state —
/// stores a catalog id, so renaming an ingredient never orphans anything.
@Riverpod(keepAlive: true)
class IngredientCatalog extends _$IngredientCatalog {
  Future<IngredientCatalogRepository> get _repo =>
      ref.read(ingredientCatalogRepositoryProvider.future);

  @override
  Future<List<IngredientCatalogEntry>> build() async {
    final repo = await ref.watch(ingredientCatalogRepositoryProvider.future);
    return repo.readAll();
  }

  List<IngredientCatalogEntry> get _entries => state.valueOrNull ?? const [];

  IngredientCatalogEntry? byId(String id) {
    for (final e in _entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// Upsert an entry. If an entry with the same id exists, it is updated.
  Future<void> upsert(IngredientCatalogEntry entry) async {
    final repo = await _repo;
    await repo.upsertEntry(entry);
    state = AsyncData(await repo.readAll());
  }

  /// Resolves free-text ingredient input to a stable catalog id.
  ///
  /// With [catalogId] given the entry keeps its identity and is renamed in
  /// place — that is what makes a typo fix in a recipe leave the shopping
  /// list's checkmarks alone. Without one, an existing entry with the same
  /// name is reused before a new id is minted.
  ///
  /// Empty defaults never overwrite what the catalog already knows.
  Future<String> resolve({
    String? catalogId,
    required String name,
    String unit = '',
    String category = '',
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Ingredient name is required');
    }
    final trimmedUnit = unit.trim();
    final trimmedCategory = category.trim();

    final existing = catalogId != null
        ? byId(catalogId)
        : _findByName(trimmedName);

    if (existing == null) {
      final entry = IngredientCatalogEntry(
        id: catalogId ?? _uuid.v4(),
        name: trimmedName,
        defaultUnit: trimmedUnit,
        defaultCategory: trimmedCategory,
      );
      await upsert(entry);
      return entry.id;
    }

    final updated = existing.copyWith(
      name: trimmedName,
      defaultUnit:
          trimmedUnit.isNotEmpty ? trimmedUnit : existing.defaultUnit,
      defaultCategory:
          trimmedCategory.isNotEmpty ? trimmedCategory : existing.defaultCategory,
    );
    if (updated != existing) await upsert(updated);
    return updated.id;
  }

  IngredientCatalogEntry? _findByName(String name) {
    final key = name.trim().toLowerCase();
    for (final e in _entries) {
      if (e.nameKey == key) return e;
    }
    return null;
  }

  /// Find matching entries for autocomplete.
  List<IngredientCatalogEntry> search(String query) {
    final entries = _entries;
    if (query.trim().isEmpty) return entries;
    final lower = query.trim().toLowerCase();
    return entries
        .where((e) => e.name.toLowerCase().contains(lower))
        .toList();
  }
}

/// Catalog entries by id, for the many places that need to turn an id back
/// into a display name.
@riverpod
Future<Map<String, IngredientCatalogEntry>> catalogById(
  CatalogByIdRef ref,
) async {
  final entries = await ref.watch(ingredientCatalogProvider.future);
  return {for (final e in entries) e.id: e};
}
