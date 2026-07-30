import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/models.dart';

void main() {
  group('Recipe JSON roundtrip', () {
    test('fromJson → toJson is stable', () {
      final recipe = Recipe(
        id: 'r1',
        name: 'Pasta Bolognese',
        description: 'Klassiker',
        servings: 4,
        ingredients: [
          Ingredient(catalogId: 'c-spaghetti', amount: 500, unit: 'g'),
          Ingredient(catalogId: 'c-hack', amount: 400, unit: 'g'),
        ],
        tags: ['italienisch', 'schnell'],
      );

      final json = recipe.toJson();
      final restored = Recipe.fromJson(json);

      expect(restored, equals(recipe));
      // Double roundtrip
      expect(
        jsonEncode(restored.toJson()),
        equals(jsonEncode(recipe.toJson())),
      );
    });

    test('carries soft-delete markers', () {
      final at = DateTime.utc(2026, 3, 1, 12);
      final recipe =
          Recipe(id: 'r1', name: 'Pasta', deleted: true, deletedAt: at);

      final restored = Recipe.fromJson(recipe.toJson());
      expect(restored.deleted, isTrue);
      expect(restored.deletedAt, at);
    });
  });

  group('WeekPlan JSON roundtrip', () {
    test('fromJson → toJson is stable', () {
      final plan = WeekPlan(
        weekKey: '2025-W14',
        days: {
          'mon': DayPlan(
            morning: MealSlot(recipeId: 'r1', servings: 2),
            lunch: null,
            dinner: MealSlot(recipeId: 'r2', servings: 4),
          ),
          'tue': DayPlan(),
        },
      );

      final json = plan.toJson();
      final restored = WeekPlan.fromJson(json);

      expect(restored, equals(plan));
      expect(jsonEncode(restored.toJson()), equals(jsonEncode(plan.toJson())));
    });

    test('keeps shopping state keyed by catalog id', () {
      final plan = WeekPlan(
        weekKey: '2025-W14',
        checkedIds: {'c-milch'},
        unavailableIds: {'c-hefe'},
        excludedGeneralIds: {'c-seife'},
        quickAdds: [QuickAddItem(catalogId: 'c-chips', amount: 2)],
        amountOverrides: {
          'c-milch': ShoppingAmount(amount: 3, unit: 'l'),
        },
      );

      final restored = WeekPlan.fromJson(plan.toJson());
      expect(restored, equals(plan));
      expect(restored.amountOverrides['c-milch']?.unit, 'l');
      expect(restored.quickAdds.single.catalogId, 'c-chips');
    });
  });

  group('ShoppingItem JSON roundtrip', () {
    test('preserves source enum and per-unit amounts', () {
      final item = ShoppingItem(
        catalogId: 'c-milch',
        name: 'Milch',
        category: 'Milchprodukte',
        amounts: [
          ShoppingAmount(amount: 1, unit: 'l'),
          ShoppingAmount(amount: 2, unit: 'Packung'),
        ],
        source: ShoppingSource.recipe,
      );

      final restored = ShoppingItem.fromJson(item.toJson());
      expect(restored, equals(item));
      expect(restored.source, ShoppingSource.recipe);
      expect(restored.amounts.length, 2);
    });
  });

  group('GeneralItem JSON roundtrip', () {
    test('fromJson → toJson is stable', () {
      final item = GeneralItem(
        catalogId: 'c-kuechenpapier',
        amount: 2,
        unit: 'Rollen',
      );

      final restored = GeneralItem.fromJson(item.toJson());
      expect(restored, equals(item));
      expect(restored.id, 'c-kuechenpapier');
    });
  });

  group('IngredientCatalogEntry', () {
    test('nameKey normalises case and padding', () {
      const entry = IngredientCatalogEntry(id: 'c1', name: '  Weizenmehl ');
      expect(entry.nameKey, 'weizenmehl');
    });

    test('roundtrips through JSON', () {
      const entry = IngredientCatalogEntry(
        id: 'c1',
        name: 'Mehl',
        defaultUnit: 'g',
        defaultCategory: 'Backen',
      );
      expect(IngredientCatalogEntry.fromJson(entry.toJson()), equals(entry));
    });
  });
}
