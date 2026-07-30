import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/models.dart';
import 'package:meal_planner/providers/current_week_provider.dart';
import 'package:meal_planner/providers/derived_shopping_list_provider.dart';
import 'package:meal_planner/providers/general_items_provider.dart';
import 'package:meal_planner/providers/ingredient_catalog_provider.dart';
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
    List<IngredientCatalogEntry> initialCatalog = const [],
  }) async {
    final storage = FileStorageBackend(directoryOverride: tmpDir);
    final recipeRepo = RecipeRepository(storage: storage);
    final weekPlanRepo = WeekPlanRepository(storage: storage);
    final generalRepo = GeneralItemRepository(storage: storage);
    final catalogRepo = IngredientCatalogRepository(storage: storage);

    // Pre-seed data — await so files exist before providers read them
    for (final r in initialRecipes) {
      await recipeRepo.upsertRecipe(r);
    }
    for (final w in initialWeekPlans) {
      await weekPlanRepo.upsertWeekPlan(w);
    }
    for (final g in initialGeneralItems) {
      await generalRepo.upsertItem(g);
    }
    for (final c in initialCatalog) {
      await catalogRepo.upsertEntry(c);
    }

    final container = ProviderContainer(
      overrides: [
        recipeRepositoryProvider.overrideWith((ref) async => recipeRepo),
        weekPlanRepositoryProvider.overrideWith((ref) async => weekPlanRepo),
        generalItemRepositoryProvider.overrideWith((ref) async => generalRepo),
        ingredientCatalogRepositoryProvider
            .overrideWith((ref) async => catalogRepo),
      ],
    );

    addTearDown(container.dispose);
    return container;
  }

  /// Catalog entries used by most shopping-list tests.
  const spaghetti =
      IngredientCatalogEntry(id: 'c-spaghetti', name: 'Spaghetti');
  const sauce = IngredientCatalogEntry(id: 'c-sauce', name: 'Sauce');
  const butter = IngredientCatalogEntry(id: 'c-butter', name: 'Butter');
  const brot = IngredientCatalogEntry(id: 'c-brot', name: 'Brot');
  const papier =
      IngredientCatalogEntry(id: 'c-papier', name: 'Küchenpapier');
  const seife = IngredientCatalogEntry(id: 'c-seife', name: 'Seife');

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

    test('toggleChecked stores the catalog id', () async {
      final container = await createContainer();
      // Hold the provider alive; auto-dispose between awaits would reset it.
      final sub =
          container.listen(weekPlanNotifierProvider('2025-W14'), (_, _) {});
      addTearDown(sub.close);
      await container.read(weekPlanNotifierProvider('2025-W14').future);
      final notifier =
          container.read(weekPlanNotifierProvider('2025-W14').notifier);

      await notifier.toggleChecked('c-milch');
      expect(
        (await container.read(weekPlanNotifierProvider('2025-W14').future))
            .checkedIds,
        {'c-milch'},
      );

      await notifier.toggleChecked('c-milch');
      expect(
        (await container.read(weekPlanNotifierProvider('2025-W14').future))
            .checkedIds,
        isEmpty,
      );
    });

    test('quick-adding the same ingredient twice tops up one entry', () async {
      final container = await createContainer();
      final sub =
          container.listen(weekPlanNotifierProvider('2025-W14'), (_, _) {});
      addTearDown(sub.close);
      await container.read(weekPlanNotifierProvider('2025-W14').future);
      final notifier =
          container.read(weekPlanNotifierProvider('2025-W14').notifier);

      await notifier.addQuickAdd(const QuickAddItem(catalogId: 'c-x', amount: 1));
      await notifier.addQuickAdd(const QuickAddItem(catalogId: 'c-x', amount: 2));

      final plan =
          await container.read(weekPlanNotifierProvider('2025-W14').future);
      expect(plan.quickAdds, hasLength(1));
      expect(plan.quickAdds.single.amount, 3);
    });
  });

  group('generalItemsProvider', () {
    test('loads and upserts general items', () async {
      final container = await createContainer(
        initialGeneralItems: [const GeneralItem(catalogId: 'c-seife')],
      );

      var items = await container.read(generalItemsProvider.future);
      expect(items.length, 1);

      await container.read(generalItemsProvider.notifier).upsert(
            const GeneralItem(catalogId: 'c-schwamm'),
          );

      items = await container.read(generalItemsProvider.future);
      expect(items.length, 2);
    });
  });

  group('ingredientCatalogProvider.resolve', () {
    test('reuses an existing entry with the same name', () async {
      final container = await createContainer(initialCatalog: [butter]);
      await container.read(ingredientCatalogProvider.future);

      final id = await container
          .read(ingredientCatalogProvider.notifier)
          .resolve(name: 'butter');

      expect(id, 'c-butter');
      expect(await container.read(ingredientCatalogProvider.future),
          hasLength(1));
    });

    test('mints a new id for an unknown name', () async {
      final container = await createContainer();
      await container.read(ingredientCatalogProvider.future);

      final id = await container
          .read(ingredientCatalogProvider.notifier)
          .resolve(name: 'Zimt', unit: 'TL', category: 'Gewürze');

      final entries = await container.read(ingredientCatalogProvider.future);
      expect(entries.single.id, id);
      expect(entries.single.defaultUnit, 'TL');
    });

    test('renaming with a known id keeps that id', () async {
      final container = await createContainer(initialCatalog: [butter]);
      await container.read(ingredientCatalogProvider.future);

      final id = await container
          .read(ingredientCatalogProvider.notifier)
          .resolve(catalogId: 'c-butter', name: 'Süßrahmbutter');

      expect(id, 'c-butter');
      final entries = await container.read(ingredientCatalogProvider.future);
      expect(entries, hasLength(1));
      expect(entries.single.name, 'Süßrahmbutter');
    });

    test('empty defaults do not overwrite what the catalog knows', () async {
      final container = await createContainer(initialCatalog: [
        const IngredientCatalogEntry(
          id: 'c1',
          name: 'Mehl',
          defaultUnit: 'g',
          defaultCategory: 'Backen',
        ),
      ]);
      await container.read(ingredientCatalogProvider.future);

      await container
          .read(ingredientCatalogProvider.notifier)
          .resolve(catalogId: 'c1', name: 'Mehl');

      final entry =
          (await container.read(ingredientCatalogProvider.future)).single;
      expect(entry.defaultUnit, 'g');
      expect(entry.defaultCategory, 'Backen');
    });
  });

  group('derivedShoppingListProvider', () {
    test('aggregates recipe ingredients scaled by servings', () async {
      final container = await createContainer(
        initialCatalog: [spaghetti, sauce],
        initialRecipes: [
          Recipe(
            id: 'r1',
            name: 'Pasta',
            servings: 2,
            ingredients: [
              Ingredient(catalogId: 'c-spaghetti', amount: 250, unit: 'g'),
              Ingredient(catalogId: 'c-sauce', amount: 200, unit: 'ml'),
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

      final line = list.firstWhere((s) => s.catalogId == 'c-spaghetti');
      expect(line.name, 'Spaghetti');
      expect(line.amounts.single, const ShoppingAmount(amount: 500, unit: 'g'));
      expect(line.source, ShoppingSource.recipe);

      final sauceLine = list.firstWhere((s) => s.catalogId == 'c-sauce');
      expect(sauceLine.amounts.single,
          const ShoppingAmount(amount: 400, unit: 'ml'));
    });

    test('combines recipe ingredients with general items', () async {
      final container = await createContainer(
        initialCatalog: [brot, papier],
        initialRecipes: [
          Recipe(
            id: 'r1',
            name: 'Toast',
            servings: 1,
            ingredients: [
              Ingredient(catalogId: 'c-brot', amount: 4, unit: 'Scheiben'),
            ],
          ),
        ],
        initialWeekPlans: [
          WeekPlan(weekKey: '2025-W14', days: {
            'mon': DayPlan(morning: MealSlot(recipeId: 'r1', servings: 1)),
          }),
        ],
        initialGeneralItems: [
          const GeneralItem(catalogId: 'c-papier', amount: 2, unit: 'Rollen'),
        ],
      );

      container.read(currentWeekKeyProvider.notifier).set('2025-W14');

      final list = await container.read(derivedShoppingListProvider.future);

      expect(
          list.any((s) =>
              s.catalogId == 'c-brot' && s.source == ShoppingSource.recipe),
          isTrue);
      expect(
          list.any((s) =>
              s.catalogId == 'c-papier' &&
              s.source == ShoppingSource.general),
          isTrue);
    });

    test('a general item also used by a recipe counts as merged', () async {
      final container = await createContainer(
        initialCatalog: [butter],
        initialRecipes: [
          Recipe(
            id: 'r1',
            name: 'Toast',
            servings: 1,
            ingredients: [
              Ingredient(catalogId: 'c-butter', amount: 20, unit: 'g'),
            ],
          ),
        ],
        initialWeekPlans: [
          WeekPlan(weekKey: '2025-W14', days: {
            'mon': DayPlan(morning: MealSlot(recipeId: 'r1', servings: 1)),
          }),
        ],
        initialGeneralItems: [
          const GeneralItem(catalogId: 'c-butter', amount: 250, unit: 'g'),
        ],
      );

      container.read(currentWeekKeyProvider.notifier).set('2025-W14');

      final list = await container.read(derivedShoppingListProvider.future);
      final line = list.single;
      expect(line.source, ShoppingSource.merged);
      expect(line.amounts.single, const ShoppingAmount(amount: 270, unit: 'g'));
    });

    test('excluded general items drop out of the week', () async {
      final container = await createContainer(
        initialCatalog: [seife],
        initialWeekPlans: [
          WeekPlan(weekKey: '2025-W14', excludedGeneralIds: {'c-seife'}),
        ],
        initialGeneralItems: [const GeneralItem(catalogId: 'c-seife')],
      );

      container.read(currentWeekKeyProvider.notifier).set('2025-W14');

      expect(await container.read(derivedShoppingListProvider.future), isEmpty);
    });

    test('aggregates same ingredient across multiple meals', () async {
      final container = await createContainer(
        initialCatalog: [butter],
        initialRecipes: [
          Recipe(
            id: 'r1',
            name: 'Pasta',
            servings: 2,
            ingredients: [
              Ingredient(catalogId: 'c-butter', amount: 20, unit: 'g'),
            ],
          ),
          Recipe(
            id: 'r2',
            name: 'Toast',
            servings: 1,
            ingredients: [
              Ingredient(catalogId: 'c-butter', amount: 10, unit: 'g'),
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
      expect(list.single.amounts.single,
          const ShoppingAmount(amount: 30, unit: 'g'));
    });

    test('merges compatible units onto one line', () async {
      final container = await createContainer(
        initialCatalog: [butter],
        initialRecipes: [
          Recipe(
            id: 'r1',
            name: 'Kuchen',
            servings: 1,
            ingredients: [
              Ingredient(catalogId: 'c-butter', amount: 500, unit: 'g'),
            ],
          ),
        ],
        initialWeekPlans: [
          WeekPlan(weekKey: '2025-W14', days: {
            'mon': DayPlan(dinner: MealSlot(recipeId: 'r1', servings: 1)),
          }),
        ],
        initialGeneralItems: [
          const GeneralItem(catalogId: 'c-butter', amount: 1, unit: 'kg'),
        ],
      );

      container.read(currentWeekKeyProvider.notifier).set('2025-W14');

      final list = await container.read(derivedShoppingListProvider.future);
      expect(list.single.amounts.single,
          const ShoppingAmount(amount: 1.5, unit: 'kg'));
    });

    test('keeps incompatible units side by side on one line', () async {
      final container = await createContainer(
        initialCatalog: [butter],
        initialWeekPlans: [
          WeekPlan(
            weekKey: '2025-W14',
            quickAdds: [
              const QuickAddItem(
                  catalogId: 'c-butter', amount: 2, unit: 'Packung'),
            ],
          ),
        ],
        initialGeneralItems: [
          const GeneralItem(catalogId: 'c-butter', amount: 250, unit: 'g'),
        ],
      );

      container.read(currentWeekKeyProvider.notifier).set('2025-W14');

      final line =
          (await container.read(derivedShoppingListProvider.future)).single;
      expect(line.amounts, [
        const ShoppingAmount(amount: 250, unit: 'g'),
        const ShoppingAmount(amount: 2, unit: 'Packung'),
      ]);
      expect(line.hasQuickAdd, isTrue);
    });

    test('an amount override replaces the derived amounts', () async {
      final container = await createContainer(
        initialCatalog: [butter],
        initialWeekPlans: [
          WeekPlan(
            weekKey: '2025-W14',
            amountOverrides: {
              'c-butter': const ShoppingAmount(amount: 3, unit: 'Stk'),
            },
          ),
        ],
        initialGeneralItems: [
          const GeneralItem(catalogId: 'c-butter', amount: 250, unit: 'g'),
        ],
      );

      container.read(currentWeekKeyProvider.notifier).set('2025-W14');

      final line =
          (await container.read(derivedShoppingListProvider.future)).single;
      expect(line.amounts, [const ShoppingAmount(amount: 3, unit: 'Stk')]);
    });

    test('a line whose catalog entry is missing still shows up', () async {
      final container = await createContainer(
        initialGeneralItems: [const GeneralItem(catalogId: 'c-unbekannt')],
      );

      container.read(currentWeekKeyProvider.notifier).set('2025-W14');

      final line =
          (await container.read(derivedShoppingListProvider.future)).single;
      expect(line.catalogId, 'c-unbekannt');
      expect(line.name, 'Unbekannte Zutat');
    });

    test('recipe change triggers recalculation', () async {
      final container = await createContainer(
        initialCatalog: [spaghetti],
        initialRecipes: [
          Recipe(
            id: 'r1',
            name: 'Pasta',
            servings: 2,
            ingredients: [
              Ingredient(catalogId: 'c-spaghetti', amount: 250, unit: 'g'),
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

      var list = await container.read(derivedShoppingListProvider.future);
      expect(list.single.amounts.single,
          const ShoppingAmount(amount: 250, unit: 'g'));

      await container.read(recipesProvider.notifier).upsert(
            Recipe(
              id: 'r1',
              name: 'Pasta',
              servings: 2,
              ingredients: [
                Ingredient(catalogId: 'c-spaghetti', amount: 500, unit: 'g'),
              ],
            ),
          );

      list = await container.read(derivedShoppingListProvider.future);
      expect(list.single.amounts.single,
          const ShoppingAmount(amount: 500, unit: 'g'));

      sub.close();
    });

    test('empty week plan produces only general items', () async {
      final container = await createContainer(
        initialCatalog: [seife],
        initialGeneralItems: [
          const GeneralItem(catalogId: 'c-seife', amount: 1, unit: 'Stück'),
        ],
      );

      container.read(currentWeekKeyProvider.notifier).set('2025-W99');

      final list = await container.read(derivedShoppingListProvider.future);
      expect(list.length, 1);
      expect(list.first.name, 'Seife');
      expect(list.first.source, ShoppingSource.general);
    });
  });

  // The point of issue #5: shopping state hangs off catalog ids, so editing
  // an ingredient must not silently un-tick it mid-shopping.
  group('stable identity (#5)', () {
    Future<ProviderContainer> checkedButterWeek() => createContainer(
          initialCatalog: [
            const IngredientCatalogEntry(
              id: 'c-butter',
              name: 'Butter',
              defaultUnit: 'g',
            ),
          ],
          initialRecipes: [
            Recipe(
              id: 'r1',
              name: 'Kuchen',
              servings: 1,
              ingredients: [
                Ingredient(catalogId: 'c-butter', amount: 250, unit: 'g'),
              ],
            ),
          ],
          initialWeekPlans: [
            WeekPlan(
              weekKey: '2025-W14',
              days: {
                'mon': DayPlan(dinner: MealSlot(recipeId: 'r1', servings: 1)),
              },
              checkedIds: {'c-butter'},
            ),
          ],
        );

    test('renaming an ingredient keeps the line checked', () async {
      final container = await checkedButterWeek();
      container.read(currentWeekKeyProvider.notifier).set('2025-W14');
      final sub = container.listen(derivedShoppingListProvider, (_, _) {});
      addTearDown(sub.close);
      await container.read(ingredientCatalogProvider.future);

      await container
          .read(ingredientCatalogProvider.notifier)
          .resolve(catalogId: 'c-butter', name: 'Süßrahmbutter');

      final line =
          (await container.read(derivedShoppingListProvider.future)).single;
      final plan =
          await container.read(weekPlanNotifierProvider('2025-W14').future);

      expect(line.name, 'Süßrahmbutter');
      expect(line.catalogId, 'c-butter');
      expect(plan.checkedIds.contains(line.catalogId), isTrue);
    });

    test('changing the unit keeps the line checked', () async {
      final container = await checkedButterWeek();
      container.read(currentWeekKeyProvider.notifier).set('2025-W14');
      final sub = container.listen(derivedShoppingListProvider, (_, _) {});
      addTearDown(sub.close);
      await container.read(ingredientCatalogProvider.future);

      await container.read(recipesProvider.notifier).upsert(
            Recipe(
              id: 'r1',
              name: 'Kuchen',
              servings: 1,
              ingredients: [
                // same ingredient, now measured in packs
                Ingredient(catalogId: 'c-butter', amount: 2, unit: 'Packung'),
              ],
            ),
          );

      final line =
          (await container.read(derivedShoppingListProvider.future)).single;
      final plan =
          await container.read(weekPlanNotifierProvider('2025-W14').future);

      expect(line.amounts.single,
          const ShoppingAmount(amount: 2, unit: 'Packung'));
      expect(plan.checkedIds.contains(line.catalogId), isTrue);
    });
  });
}
