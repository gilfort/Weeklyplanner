import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../models/ingredient.dart';
import '../models/meal_slot.dart';
import '../models/recipe.dart';
import '../models/shopping_item.dart';
import 'current_week_provider.dart';
import 'recipe_provider.dart';
import 'week_plan_provider.dart';
import 'general_items_provider.dart';

part 'derived_shopping_list_provider.g.dart';

/// Pure derived provider — no own state.
/// Aggregates scaled recipe ingredients from the active week plan
/// and combines them with general items into a unified shopping list.
@riverpod
Future<List<ShoppingItem>> derivedShoppingList(
  DerivedShoppingListRef ref,
) async {
  final weekKey = ref.watch(currentWeekKeyProvider);

  // Properly await all async providers
  final weekPlan = await ref.watch(weekPlanNotifierProvider(weekKey).future);
  final recipes = await ref.watch(recipesProvider.future);
  final generalItems = await ref.watch(generalItemsProvider.future);

  // Build a lookup map: recipeId → Recipe
  final recipeMap = {for (final r in recipes) r.id: r};

  // Collect all meal slots from every day
  final allSlots = <MealSlot>[];
  for (final day in weekPlan.days.values) {
    if (day.morning != null) allSlots.add(day.morning!);
    if (day.lunch != null) allSlots.add(day.lunch!);
    if (day.dinner != null) allSlots.add(day.dinner!);
    if (day.snack != null) allSlots.add(day.snack!);
  }

  // Aggregate ingredients: key = "name|unit" → accumulated amount
  final aggregated = <String, _AggregatedIngredient>{};

  for (final slot in allSlots) {
    if (slot.recipeId == null) continue;
    final recipe = recipeMap[slot.recipeId];
    if (recipe == null) continue;

    final servings = slot.servings ?? recipe.servings;
    final scaled = _scaleIngredients(recipe, servings);

    for (final ing in scaled) {
      final key = '${ing.name.toLowerCase()}|${ing.unit.toLowerCase()}';
      if (aggregated.containsKey(key)) {
        aggregated[key] = aggregated[key]!.add(ing.amount);
      } else {
        aggregated[key] = _AggregatedIngredient(
          name: ing.name,
          amount: ing.amount,
          unit: ing.unit,
          category: ing.category,
        );
      }
    }
  }

  // Merge general items into the same aggregation map.
  // If a general item matches a recipe ingredient by name|unit, amounts add up.
  final mergedKeys = <String>{};
  for (final g in generalItems) {
    final key = '${g.name.toLowerCase()}|${g.unit.toLowerCase()}';
    if (aggregated.containsKey(key)) {
      aggregated[key] = aggregated[key]!.add(g.amount, merged: true);
      mergedKeys.add(key);
    } else {
      aggregated[key] = _AggregatedIngredient(
        name: g.name,
        amount: g.amount,
        unit: g.unit,
        category: g.category.isNotEmpty ? g.category : '',
        isMerged: false,
        isGeneral: true,
      );
    }
  }

  const uuid = Uuid();

  return aggregated.entries.map((e) {
    final agg = e.value;
    final ShoppingSource source;
    if (mergedKeys.contains(e.key)) {
      source = ShoppingSource.merged;
    } else if (agg.isGeneral) {
      source = ShoppingSource.general;
    } else {
      source = ShoppingSource.recipe;
    }
    return ShoppingItem(
      id: uuid.v4(),
      name: agg.name,
      amount: agg.amount,
      unit: agg.unit,
      category: agg.category,
      source: source,
    );
  }).toList();
}

List<Ingredient> _scaleIngredients(Recipe recipe, int targetServings) {
  if (recipe.servings <= 0) return recipe.ingredients;
  final factor = targetServings / recipe.servings;
  return recipe.ingredients
      .map((i) => i.copyWith(amount: i.amount * factor))
      .toList();
}

class _AggregatedIngredient {
  final String name;
  final double amount;
  final String unit;
  final String category;
  final bool isMerged;
  final bool isGeneral;

  const _AggregatedIngredient({
    required this.name,
    required this.amount,
    required this.unit,
    required this.category,
    this.isMerged = false,
    this.isGeneral = false,
  });

  _AggregatedIngredient add(double extra, {bool merged = false}) =>
      _AggregatedIngredient(
        name: name,
        amount: amount + extra,
        unit: unit,
        category: category,
        isMerged: isMerged || merged,
        isGeneral: isGeneral,
      );
}
