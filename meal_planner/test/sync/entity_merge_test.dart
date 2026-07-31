import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/models.dart';
import 'package:meal_planner/sync/entity_merge.dart';

void main() {
  group('mergeRecipe', () {
    final base = Recipe(
      id: 'r1',
      name: 'Pasta',
      servings: 2,
      ingredients: [Ingredient(catalogId: 'c-nudeln', amount: 250, unit: 'g')],
    );

    test('keeps independent field changes from both sides', () {
      final local = base.copyWith(name: 'Pasta Bolognese');
      final remote = base.copyWith(servings: 4);

      final merged = mergeRecipe(base, local, remote, preferRemote: false);

      expect(merged.name, 'Pasta Bolognese');
      expect(merged.servings, 4);
    });

    test('does not treat an untouched ingredient list as a conflict', () {
      // Same content, fresh list instances — the common case after a reload.
      final local = base.copyWith(
        name: 'Penne',
        ingredients: [
          Ingredient(catalogId: 'c-nudeln', amount: 250, unit: 'g'),
        ],
      );
      final remote = base.copyWith(
        ingredients: [
          Ingredient(catalogId: 'c-nudeln', amount: 500, unit: 'g'),
        ],
      );

      final merged = mergeRecipe(base, local, remote, preferRemote: false);

      expect(merged.name, 'Penne');
      expect(merged.ingredients.single.amount, 500);
    });

    test('the newer side wins when both edited the same field', () {
      final local = base.copyWith(name: 'A');
      final remote = base.copyWith(name: 'B');

      expect(mergeRecipe(base, local, remote, preferRemote: true).name, 'B');
      expect(mergeRecipe(base, local, remote, preferRemote: false).name, 'A');
    });

    test('a deletion wins over a concurrent edit', () {
      final at = DateTime.utc(2026, 5, 1);
      final local = base.copyWith(name: 'Umbenannt');
      final remote = base.copyWith(deleted: true, deletedAt: at);

      final merged = mergeRecipe(base, local, remote, preferRemote: false);

      expect(merged.deleted, isTrue);
      expect(merged.deletedAt, at);
    });
  });

  group('mergeGeneralItem', () {
    test('merges amount and unit independently', () {
      const base = GeneralItem(catalogId: 'c1', amount: 1, unit: 'Stk');
      final local = base.copyWith(amount: 3);
      final remote = base.copyWith(unit: 'Packung');

      final merged =
          mergeGeneralItem(base, local, remote, preferRemote: false);

      expect(merged.amount, 3);
      expect(merged.unit, 'Packung');
    });
  });

  group('mergeCatalogEntry', () {
    test('a rename on one side survives a category edit on the other', () {
      const base = IngredientCatalogEntry(id: 'c1', name: 'Mehl');
      final local = base.copyWith(name: 'Weizenmehl');
      final remote = base.copyWith(defaultCategory: 'Backen');

      final merged =
          mergeCatalogEntry(base, local, remote, preferRemote: false);

      expect(merged.id, 'c1');
      expect(merged.name, 'Weizenmehl');
      expect(merged.defaultCategory, 'Backen');
    });
  });

  group('mergeDayPlan', () {
    test('merges slot by slot', () {
      const base = DayPlan();
      const local = DayPlan(lunch: MealSlot(recipeId: 'r1'));
      const remote = DayPlan(dinner: MealSlot(recipeId: 'r2'));

      final merged = mergeDayPlan(base, local, remote, preferRemote: false);

      expect(merged.lunch?.recipeId, 'r1');
      expect(merged.dinner?.recipeId, 'r2');
    });

    test('clearing a slot on one side sticks', () {
      const base = DayPlan(lunch: MealSlot(recipeId: 'r1'));
      const local = DayPlan(lunch: MealSlot(recipeId: 'r1'));
      const remote = DayPlan();

      expect(
        mergeDayPlan(base, local, remote, preferRemote: false).lunch,
        isNull,
      );
    });
  });

  group('mergeWeekPlan', () {
    // The scenario the whole rework exists for: one person edits the plan at
    // home while the other ticks items off in the shop.
    final base = WeekPlan(
      weekKey: '2025-W14',
      days: {'mon': const DayPlan(lunch: MealSlot(recipeId: 'r1'))},
      checkedIds: {'c-milch'},
    );

    test('a plan edit and a shopping tick both survive', () {
      final atHome = base.copyWith(
        days: {
          'mon': const DayPlan(lunch: MealSlot(recipeId: 'r1')),
          'thu': const DayPlan(dinner: MealSlot(recipeId: 'r9')),
        },
      );
      final inTheShop = base.copyWith(checkedIds: {'c-milch', 'c-butter'});

      final merged =
          mergeWeekPlan(base, atHome, inTheShop, preferRemote: false);

      expect(merged.days['thu']?.dinner?.recipeId, 'r9');
      expect(merged.checkedIds, {'c-milch', 'c-butter'});
    });

    test('unchecking in the shop is not undone by the other device', () {
      final atHome = base.copyWith(checkedIds: {'c-milch', 'c-brot'});
      final inTheShop = base.copyWith(checkedIds: const <String>{});

      final merged =
          mergeWeekPlan(base, atHome, inTheShop, preferRemote: false);

      expect(merged.checkedIds, {'c-brot'});
    });

    test('quick-adds from both devices are kept', () {
      final atHome = base.copyWith(
        quickAdds: [const QuickAddItem(catalogId: 'c-chips', amount: 1)],
      );
      final inTheShop = base.copyWith(
        quickAdds: [const QuickAddItem(catalogId: 'c-eis', amount: 2)],
      );

      final merged =
          mergeWeekPlan(base, atHome, inTheShop, preferRemote: false);

      expect(
        merged.quickAdds.map((q) => q.catalogId),
        unorderedEquals(['c-chips', 'c-eis']),
      );
    });

    test('the same quick-add topped up on both sides resolves by recency', () {
      final withOne = base.copyWith(
        quickAdds: [const QuickAddItem(catalogId: 'c-chips', amount: 1)],
      );
      final atHome = base.copyWith(
        quickAdds: [const QuickAddItem(catalogId: 'c-chips', amount: 2)],
      );
      final inTheShop = base.copyWith(
        quickAdds: [const QuickAddItem(catalogId: 'c-chips', amount: 5)],
      );

      final merged =
          mergeWeekPlan(withOne, atHome, inTheShop, preferRemote: true);

      expect(merged.quickAdds.single.amount, 5);
    });

    test('amount overrides merge per ingredient', () {
      final atHome = base.copyWith(
        amountOverrides: {
          'c-milch': const ShoppingAmount(amount: 2, unit: 'l'),
        },
      );
      final inTheShop = base.copyWith(
        amountOverrides: {
          'c-brot': const ShoppingAmount(amount: 1, unit: 'Stk'),
        },
      );

      final merged =
          mergeWeekPlan(base, atHome, inTheShop, preferRemote: false);

      expect(merged.amountOverrides.keys, unorderedEquals(['c-milch', 'c-brot']));
    });

    test('both devices reach the same result', () {
      final atHome = base.copyWith(
        checkedIds: {'c-milch', 'c-brot'},
        days: {
          'mon': const DayPlan(lunch: MealSlot(recipeId: 'r1')),
          'thu': const DayPlan(dinner: MealSlot(recipeId: 'r9')),
        },
      );
      final inTheShop = base.copyWith(
        checkedIds: const <String>{},
        excludedGeneralIds: {'c-seife'},
      );

      // Same base, sides swapped, and the conflict tiebreak swapped with
      // them — the two devices must converge on one file.
      final fromHome =
          mergeWeekPlan(base, atHome, inTheShop, preferRemote: false);
      final fromShop =
          mergeWeekPlan(base, inTheShop, atHome, preferRemote: true);

      expect(fromHome, equals(fromShop));
    });
  });
}
