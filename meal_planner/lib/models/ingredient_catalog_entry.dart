import 'package:freezed_annotation/freezed_annotation.dart';

part 'ingredient_catalog_entry.freezed.dart';
part 'ingredient_catalog_entry.g.dart';

/// A known ingredient with its default unit and category.
/// Built automatically from recipe and general-item usage.
@freezed
abstract class IngredientCatalogEntry with _$IngredientCatalogEntry {
  const factory IngredientCatalogEntry({
    required String id, // lowercase name as stable key
    required String name,
    @Default('') String defaultUnit,
    @Default('') String defaultCategory,
  }) = _IngredientCatalogEntry;

  factory IngredientCatalogEntry.fromJson(Map<String, dynamic> json) =>
      _$IngredientCatalogEntryFromJson(json);
}
