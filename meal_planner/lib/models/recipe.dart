import 'package:freezed_annotation/freezed_annotation.dart';
import 'ingredient.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

@freezed
abstract class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    required String name,
    @Default('') String description,
    @Default(2) int servings,
    @Default([]) List<Ingredient> ingredients,
    @Default([]) List<String> tags,
    @Default(false) bool deleted,
    DateTime? deletedAt,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) =>
      _$RecipeFromJson(json);
}
