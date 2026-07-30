import 'package:freezed_annotation/freezed_annotation.dart';

part 'ingredient.freezed.dart';
part 'ingredient.g.dart';

/// One ingredient line of a recipe.
///
/// Carries no name or category of its own — those live on the
/// [IngredientCatalogEntry] referenced by [catalogId]. That way renaming an
/// ingredient (or fixing its category) updates every recipe at once and never
/// orphans the week's checked-off shopping state.
@freezed
abstract class Ingredient with _$Ingredient {
  const factory Ingredient({
    required String catalogId,
    required double amount,
    @Default('') String unit,
  }) = _Ingredient;

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);
}
