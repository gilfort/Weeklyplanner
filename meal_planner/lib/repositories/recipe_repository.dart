import '../models/recipe.dart';
import '../sync/entity_merge.dart';
import 'entity_repository.dart';

class RecipeRepository extends EntityRepository<Recipe> {
  RecipeRepository({required super.storage}) : super(dirName: 'recipes');

  @override
  Recipe fromJson(Map<String, dynamic> json) => Recipe.fromJson(json);

  @override
  Map<String, dynamic> toJson(Recipe item) => item.toJson();

  @override
  String idOf(Recipe item) => item.id;

  @override
  bool isDeleted(Recipe item) => item.deleted;

  @override
  DateTime? deletedAtOf(Recipe item) => item.deletedAt;

  @override
  Recipe markDeleted(Recipe item, DateTime at) =>
      item.copyWith(deleted: true, deletedAt: at);

  @override
  Recipe merge(Recipe base, Recipe local, Recipe remote,
          {required bool preferRemote}) =>
      mergeRecipe(base, local, remote, preferRemote: preferRemote);

  Future<void> upsertRecipe(Recipe recipe) => upsert(recipe);

  Future<bool> deleteRecipe(String id, {DateTime? now}) => delete(id, now: now);
}
