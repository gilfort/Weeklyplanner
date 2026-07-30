import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/models.dart';
import 'package:meal_planner/providers/current_week_provider.dart';
import 'package:meal_planner/providers/derived_shopping_list_provider.dart';
import 'package:meal_planner/providers/general_items_provider.dart';
import 'package:meal_planner/providers/recipe_provider.dart';
import 'package:meal_planner/providers/repository_providers.dart';
import 'package:meal_planner/providers/week_plan_provider.dart';
import 'package:meal_planner/repositories/repositories.dart';

void main() {
  late Directory tmpDir;

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('meal_planner_prov_test_');
  });

  tearDown(() {
    try {
      if (tmpDir.existsSync()) tmpDir.deleteSync(recursive: true);
    } catch (_) {
      // Windows file-locking: best-effort cleanup
    }
  });

  /// Helper: create a ProviderContainer with repositories backed by tmpDir.
  Future<ProviderContainer> createContainer({
    List<Recipe> initialRecipes = const [],
    List<WeekPlan> initialWeekPlans = const [],
    List<GeneralItem> initialGeneralItems = const [],
  }) async {
    final storage = FileStorageBackend(directoryOverride: tmpDir);
    final recipeRepo = RecipeRepository(storage: storage);
    final weekPlanRepo = WeekPlanRepository(storage: storage);
    final generalRepo = GeneralItemRepository(storage: storage);

    // Pre-seed data — await to ensure files are written before providers read
    if (initialRecipes.isNotEmpty) {
      await recipeRepo.writeAll(initialRecipes);
    }
    if (initialWeekPlans.isNotEmpty) {
      await weekPlanRepo.writeAll(initialWeekPlans);
    }
    if (initialGeneralItems.isNotEmpty) {
      await generalRepo.writeAll(initialGeneralItems);
    }

    final container = ProviderContainer(
      overrides: [
        recipeRepositoryProvider.overrideWith((ref) async => recipeRepo),
        weekPlanRepositoryProvider.overrideWith((ref) async => weekPlanRepo),
        generalItemRepositoryProvider.overrideWith((ref) async => generalRepo),
      ],
    );

    addTearDown(container.dispose);
    return container;
  }

  group('recipesProvider', () {
    test('loads recipes from repository', () async {
      final container = await createContainer(
        initialRecipes: [
          Recipe(id: 'r1', name: 'Pasta', servings: 2),
        ],
      );

      final recipes = await container.read(recipesProvider.future);
      expect(recipes.length, 1);
      expect(recipes.first.name, 'Pasta');
    });

    test('upsert adds a new recipe', () async {
      final container = await createContainer();

      await container.read(recipesProvider.future);
      await container.read(recipesProvider.notifier).upsert(
            Recipe(id: 'r1', name: 'Salat', servings: 1),
          );

      final recipes = await container.read(recipesProvider.future);
      expect(recipes.length, 1);
      expect(recipes.first.name, 'Salat');
    });
  });

  group('weekPlanNotifierProvider (family)', () {
    test('returns empty plan for unknown weekKey', () async {
      final container = await createContainer();

      final plan =
          await container.read(weekPlanNotifierProvider('2025-W99').future);
      expect(plan.weekKey, '2025-W99');
      expect(plan.days, isEmpty);
    });

    test('loads persisted week plan', () async {
      final container = await createContainer(
        initialWeekPlans: [
          WeekPlan(weekKey: '2025-W14', days: {
            'mon': DayPlan(morning: MealSlot(recipeId: 'r1', servings: 2)),
          }),
        ],
      );

      final plan =
          await container.read(weekPlanNotifierProvider('2025-W14').future);
      expect(plan.days['mon']?.morning?.recipeId, 'r1');
    });
  });

  group('generalItemsProvider', () {
    test('loads and upserts general items', () async {
      final container = await createContainer(
        initialGeneralItems: [
          GeneralItem(id: 'g1', name: 'Seife'),
        ],
      );

      var items = await container.read(generalItemsProvider.future);
      expect(items.length, 1);

      await container.read(generalItemsProvider.notifier).upsert(
            GeneralItem(id: 'g2', name: 'Schwamm'),
          );

      items = await container.read(generalItemsProvider.future);
      expect(items.length, 2);
    });
  });

  group('derivedShoppingListProvider', () {
    test('aggregates recipe ingredients scaled by servings', () async {
      final container = await createContainer(
        initialRecipes: [
          Recipe(
            id: 'r1',
            name: 'Pasta',
            servings: 2,
            ingredients: [
              Ingredient(id: 'i1', name: 'Spaghetti', amount: 250, unit: 'g'),
              Ingredient(id: 'i2', name: 'Sauce', amount: 200, unit: 'ml'),
            ],
          ),
        ],
        initialWeekPlans: [
          WeekPlan(weekKey: '2025-W14', days: {
            'mon': DayPlan(
              dinner: MealSlot(recipeId: 'r1', servings: 4), // 2x scale
            ),
          }),
        ],
      );

      container.read(currentWeekKeyProvider.notifier).set('2025-W14');

      final list = await container.read(derivedShoppingListProvider.future);

      final spaghetti = list.firstWhere((s) => s.name == 'Spaghetti');
      expect(spaghetti.amount, 500.0); // 250 * (4/2)
      expect(spaghetti.source, ShoppingSource.recipe);

      final sauce = list.firstWhere((s) => s.name == 'Sauce');
      expect(sauce.amount, 400.0); // 200 * (4/2)
    });

    test('combines recipe ingredients with general items', () async {
      final container = await createContainer(
        initialRecipes: [
          Recipe(
            id: 'r1',
            name: 'Toast',
            servings: 1,
            ingredients: [
              Ingredient(id: 'i1', name: 'Brot', amount: 4, unit: 'Scheiben'),
            ],
          ),
        ],
        initialWeekPlans: [
          WeekPlan(weekKey: '2025-W14', days: {
            'mon': DayPlan(morning: MealSlot(recipeId: 'r1', servings: 1)),
          }),
        ],
        initialGeneralItems: [
          GeneralItem(
              id: 'g1', name: 'Küchenpapier', amount: 2, unit: 'Rollen'),
        ],
      );

      container.read(currentWeekKeyProvider.notifier).set('2025-W14');

      final list = await container.read(derivedShoppingListProvider.future);

      expect(
          list.any(
              (s) => s.name == 'Brot' && s.source == ShoppingSource.recipe),
          isTrue);
      expect(
          list.any((s) =>
              s.name == 'Küchenpapier' && s.source == ShoppingSource.general),
          isTrue);
    });

    test('aggregates same ingredient across multiple meals', () async {
      final container = await createContainer(
        initialRecipes: [
          Recipe(
            id: 'r1',
            name: 'Pasta',
            servings: 2,
            ingredients: [
              Ingredient(id: 'i1', name: 'Butter', amount: 20, unit: 'g'),
            ],
          ),
          Recipe(
            id: 'r2',
            name: 'Toast',
            servings: 1,
            ingredients: [
              Ingredient(id: 'i2', name: 'Butter', amount: 10, unit: 'g'),
            ],
          ),
        ],
        initialWeekPlans: [
          WeekPlan(weekKey: '2025-W14', days: {
            'mon': DayPlan(
              morning: MealSlot(recipeId: 'r2', servings: 1),
              dinner: MealSlot(recipeId: 'r1', servings: 2),
            ),
          }),
        ],
      );

      container.read(currentWeekKeyProvider.notifier).set('2025-W14');

      final list = await container.read(derivedShoppingListProvider.future);
      final butter = list.firstWhere((s) => s.name == 'Butter');
      expect(butter.amount, 30.0); // 20 + 10
    });

    test('recipe change triggers recalculation', () async {
      final container = await createContainer(
        initialRecipes: [
          Recipe(
            id: 'r1',
            name: 'Pasta',
            servings: 2,
            ingredients: [
              Ingredient(id: 'i1', name: 'Spaghetti', amount: 250, unit: 'g'),
            ],
          ),
        ],
        initialWeekPlans: [
          WeekPlan(weekKey: '2025-W14', days: {
            'mon': DayPlan(
              dinner: MealSlot(recipeId: 'r1', servings: 2),
            ),
          }),
        ],
      );

      container.read(currentWeekKeyProvider.notifier).set('2025-W14');

      // Keep derived provider alive so auto-dispose doesn't reset state
      final sub = container.listen(derivedShoppingListProvider, (_, _) {});

      // Initial value
      var list = await container.read(derivedShoppingListProvider.future);
      var spaghetti = list.firstWhere((s) => s.name == 'Spaghetti');
      expect(spaghetti.amount, 250.0);

      // Update the recipe — change ingredient amount
      await container.read(recipesProvider.notifier).upsert(
            Recipe(
              id: 'r1',
              name: 'Pasta',
              servings: 2,
              ingredients: [
                Ingredient(
                    id: 'i1', name: 'Spaghetti', amount: 500, unit: 'g'),
              ],
            ),
          );

      // derivedShoppingList automatically recalculates via watch chain
      list = await container.read(derivedShoppingListProvider.future);
      spaghetti = list.firstWhere((s) => s.name == 'Spaghetti');
      expect(spaghetti.amount, 500.0); // Updated!

      sub.close();
    });

    test('empty week plan produces only general items', () async {
      final container = await createContainer(
        initialGeneralItems: [
          GeneralItem(id: 'g1', name: 'Seife', amount: 1, unit: 'Stück'),
        ],
      );

      container.read(currentWeekKeyProvider.notifier).set('2025-W99');

      final list = await container.read(derivedShoppingListProvider.future);
      expect(list.length, 1);
      expect(list.first.name, 'Seife');
      expect(list.first.source, ShoppingSource.general);
    });
  });
}
