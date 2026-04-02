import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../repositories/recipe_repository.dart';
import 'repository_providers.dart';

part 'recipe_provider.g.dart';

@riverpod
class Recipes extends _$Recipes {
  late RecipeRepository _repo;

  @override
  Future<List<Recipe>> build() async {
    _repo = ref.watch(recipeRepositoryProvider);
    return _repo.readAll();
  }

  Future<void> upsert(Recipe recipe) async {
    await _repo.upsertRecipe(recipe);
    state = AsyncData(await _repo.readAll());
  }

  Future<void> delete(String id) async {
    await _repo.deleteRecipe(id);
    state = AsyncData(await _repo.readAll());
  }

  /// Scale a recipe's ingredients to a target number of servings.
  static List<Ingredient> scaleIngredients(Recipe recipe, int targetServings) {
    if (recipe.servings <= 0) return recipe.ingredients;
    final factor = targetServings / recipe.servings;
    return recipe.ingredients
        .map((i) => i.copyWith(amount: i.amount * factor))
        .toList();
  }
}
