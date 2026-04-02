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
          Ingredient(
            id: 'i1',
            name: 'Spaghetti',
            amount: 500,
            unit: 'g',
            category: 'Nudeln',
          ),
          Ingredient(
            id: 'i2',
            name: 'Hackfleisch',
            amount: 400,
            unit: 'g',
            category: 'Fleisch',
          ),
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
  });

  group('ShoppingItem JSON roundtrip', () {
    test('preserves source enum', () {
      final item = ShoppingItem(
        id: 's1',
        name: 'Milch',
        amount: 1,
        unit: 'l',
        category: 'Milchprodukte',
        isChecked: false,
        source: ShoppingSource.recipe,
      );

      final restored = ShoppingItem.fromJson(item.toJson());
      expect(restored, equals(item));
      expect(restored.source, ShoppingSource.recipe);
    });
  });

  group('GeneralItem JSON roundtrip', () {
    test('fromJson → toJson is stable', () {
      final item = GeneralItem(
        id: 'g1',
        name: 'Küchenpapier',
        amount: 2,
        unit: 'Rollen',
        category: 'Haushalt',
      );

      final restored = GeneralItem.fromJson(item.toJson());
      expect(restored, equals(item));
    });
  });
}
