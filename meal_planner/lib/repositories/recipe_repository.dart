import '../models/recipe.dart';
import 'json_file_repository.dart';

class RecipeRepository extends JsonFileRepository<Recipe> {
  RecipeRepository({required super.storage})
      : super(fileName: 'recipes.json');

  @override
  Recipe fromJson(Map<String, dynamic> json) => Recipe.fromJson(json);

  @override
  Map<String, dynamic> toJson(Recipe item) => item.toJson();

  Future<void> upsertRecipe(Recipe recipe) =>
      upsert(recipe, (r) => r.id);

  Future<bool> deleteRecipe(String id) =>
      deleteById(id, (r) => r.id);

  Future<Recipe?> findById(String id) async {
    final items = await readAll();
    try {
      return items.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
