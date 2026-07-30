import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../repositories/recipe_repository.dart';
import 'repository_providers.dart';

part 'recipe_provider.g.dart';

@riverpod
class Recipes extends _$Recipes {
  Future<RecipeRepository> get _repo =>
      ref.read(recipeRepositoryProvider.future);

  @override
  Future<List<Recipe>> build() async {
    final repo = await ref.watch(recipeRepositoryProvider.future);
    return repo.readAll();
  }

  Future<void> upsert(Recipe recipe) async {
    final repo = await _repo;
    await repo.upsertRecipe(recipe);
    state = AsyncData(await repo.readAll());
  }

  Future<void> delete(String id) async {
    final repo = await _repo;
    await repo.deleteRecipe(id);
    state = AsyncData(await repo.readAll());
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
