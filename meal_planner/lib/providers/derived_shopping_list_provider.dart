import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/ingredient.dart';
import '../models/ingredient_catalog_entry.dart';
import '../models/meal_slot.dart';
import '../models/recipe.dart';
import '../models/shopping_amount.dart';
import '../models/shopping_item.dart';
import '../models/unit_conversion.dart';
import 'current_week_provider.dart';
import 'ingredient_catalog_provider.dart';
import 'recipe_provider.dart';
import 'week_plan_provider.dart';
import 'general_items_provider.dart';

part 'derived_shopping_list_provider.g.dart';

/// Pure derived provider — no own state.
///
/// Every contribution to an ingredient collapses onto one line keyed by its
/// catalog id: scaled recipe ingredients, the general list (minus what this
/// week excludes) and the week's quick-adds. Amounts in compatible units are
/// summed, incompatible ones stay side by side. Per-week overrides replace a
/// line's amounts entirely.
@riverpod
Future<List<ShoppingItem>> derivedShoppingList(
  DerivedShoppingListRef ref,
) async {
  final weekKey = ref.watch(currentWeekKeyProvider);

  final weekPlan = await ref.watch(weekPlanNotifierProvider(weekKey).future);
  final recipes = await ref.watch(recipesProvider.future);
  final generalItems = await ref.watch(generalItemsProvider.future);
  final catalog = await ref.watch(catalogByIdProvider.future);

  final recipeMap = {for (final r in recipes) r.id: r};

  // Collect all meal slots from every day
  final allSlots = <MealSlot>[];
  for (final day in weekPlan.days.values) {
    if (day.morning != null) allSlots.add(day.morning!);
    if (day.lunch != null) allSlots.add(day.lunch!);
    if (day.dinner != null) allSlots.add(day.dinner!);
    if (day.snack != null) allSlots.add(day.snack!);
  }

  final lines = <String, _Line>{};
  _Line lineFor(String catalogId) =>
      lines.putIfAbsent(catalogId, () => _Line());

  for (final slot in allSlots) {
    if (slot.recipeId == null) continue;
    final recipe = recipeMap[slot.recipeId];
    if (recipe == null) continue;

    for (final ing in _scaleIngredients(recipe, slot.servings ?? recipe.servings)) {
      lineFor(ing.catalogId)
        ..fromRecipe = true
        ..amounts.add(ing.amount, ing.unit);
    }
  }

  for (final g in generalItems) {
    if (weekPlan.excludedGeneralIds.contains(g.catalogId)) continue;
    lineFor(g.catalogId)
      ..fromGeneral = true
      ..amounts.add(g.amount, g.unit);
  }

  for (final q in weekPlan.quickAdds) {
    lineFor(q.catalogId)
      ..hasQuickAdd = true
      ..amounts.add(q.amount, q.unit);
  }

  final overrides = weekPlan.amountOverrides;

  return [
    for (final entry in lines.entries)
      _toShoppingItem(
        entry.key,
        entry.value,
        catalog[entry.key],
        overrides[entry.key],
      ),
  ];
}

ShoppingItem _toShoppingItem(
  String catalogId,
  _Line line,
  IngredientCatalogEntry? entry,
  ShoppingAmount? override,
) {
  final ShoppingSource source;
  if (line.fromRecipe && line.fromGeneral) {
    source = ShoppingSource.merged;
  } else if (line.fromRecipe) {
    source = ShoppingSource.recipe;
  } else {
    source = ShoppingSource.general;
  }

  return ShoppingItem(
    catalogId: catalogId,
    // A missing catalog entry means the entry file has not synced yet; show a
    // placeholder rather than dropping the line, so nothing silently vanishes
    // from the list.
    name: entry?.name ?? 'Unbekannte Zutat',
    category: entry?.defaultCategory ?? '',
    amounts: override != null ? [override] : line.amounts.build(),
    source: source,
    hasQuickAdd: line.hasQuickAdd,
  );
}

List<Ingredient> _scaleIngredients(Recipe recipe, int targetServings) {
  if (recipe.servings <= 0) return recipe.ingredients;
  final factor = targetServings / recipe.servings;
  return recipe.ingredients
      .map((i) => i.copyWith(amount: i.amount * factor))
      .toList();
}

class _Line {
  final amounts = AmountAccumulator();
  bool fromRecipe = false;
  bool fromGeneral = false;
  bool hasQuickAdd = false;
}
