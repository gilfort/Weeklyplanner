import 'package:freezed_annotation/freezed_annotation.dart';

part 'ingredient_catalog_entry.freezed.dart';
part 'ingredient_catalog_entry.g.dart';

/// A known ingredient with its default unit and category.
///
/// The catalog owns ingredient *identity*: [id] is a UUID that never changes,
/// so renaming an ingredient keeps every reference intact — recipe lines,
/// general items and the week's checked-off shopping state all point at this
/// id, not at the display name.
@freezed
abstract class IngredientCatalogEntry with _$IngredientCatalogEntry {
  const IngredientCatalogEntry._();

  const factory IngredientCatalogEntry({
    /// Stable UUID. Never derived from the name.
    required String id,
    required String name,
    @Default('') String defaultUnit,
    @Default('') String defaultCategory,
    @Default(false) bool deleted,
    DateTime? deletedAt,
  }) = _IngredientCatalogEntry;

  /// Case-insensitive lookup key used to match free-text input against
  /// existing entries. Not an identity — two entries may share it after a
  /// rename, in which case the first match wins.
  String get nameKey => name.trim().toLowerCase();

  factory IngredientCatalogEntry.fromJson(Map<String, dynamic> json) =>
      _$IngredientCatalogEntryFromJson(json);
}
