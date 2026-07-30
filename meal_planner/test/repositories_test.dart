import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/models.dart';
import 'package:meal_planner/repositories/repositories.dart';

/// Helper to create a FileStorageBackend backed by a temp directory.
FileStorageBackend testStorage(Directory tmpDir) =>
    FileStorageBackend(directoryOverride: tmpDir);

void main() {
  late Directory tmpDir;

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('meal_planner_test_');
  });

  tearDown(() {
    if (tmpDir.existsSync()) tmpDir.deleteSync(recursive: true);
  });

  // ── RecipeRepository ──────────────────────────────────────────────

  group('RecipeRepository', () {
    late RecipeRepository repo;

    setUp(() {
      repo = RecipeRepository(storage: testStorage(tmpDir));
    });

    test('readAll returns empty list when file does not exist', () async {
      final items = await repo.readAll();
      expect(items, isEmpty);
    });

    test('writeAll + readAll roundtrip', () async {
      final recipes = [
        Recipe(id: 'r1', name: 'Pasta', servings: 2),
        Recipe(id: 'r2', name: 'Salat', servings: 1),
      ];
      await repo.writeAll(recipes);
      final restored = await repo.readAll();
      expect(restored, equals(recipes));
    });

    test('upsertRecipe inserts and updates', () async {
      final recipe = Recipe(id: 'r1', name: 'Pasta', servings: 2);
      await repo.upsertRecipe(recipe);

      var items = await repo.readAll();
      expect(items.length, 1);
      expect(items.first.name, 'Pasta');

      // Update
      await repo.upsertRecipe(recipe.copyWith(name: 'Penne'));
      items = await repo.readAll();
      expect(items.length, 1);
      expect(items.first.name, 'Penne');
    });

    test('deleteRecipe removes by id', () async {
      await repo.upsertRecipe(Recipe(id: 'r1', name: 'Pasta'));
      await repo.upsertRecipe(Recipe(id: 'r2', name: 'Salat'));

      final deleted = await repo.deleteRecipe('r1');
      expect(deleted, isTrue);

      final items = await repo.readAll();
      expect(items.length, 1);
      expect(items.first.id, 'r2');
    });

    test('deleteRecipe returns false for unknown id', () async {
      final deleted = await repo.deleteRecipe('nope');
      expect(deleted, isFalse);
    });

    test('findById returns item or null', () async {
      await repo.upsertRecipe(Recipe(id: 'r1', name: 'Pasta'));
      expect((await repo.findById('r1'))?.name, 'Pasta');
      expect(await repo.findById('nope'), isNull);
    });
  });

  // ── WeekPlanRepository ────────────────────────────────────────────

  group('WeekPlanRepository', () {
    late WeekPlanRepository repo;

    setUp(() {
      repo = WeekPlanRepository(storage: testStorage(tmpDir));
    });

    test('readAll returns empty list when file does not exist', () async {
      expect(await repo.readAll(), isEmpty);
    });

    test('upsert and find by weekKey', () async {
      final plan = WeekPlan(
        weekKey: '2025-W14',
        days: {
          'mon': DayPlan(
            morning: MealSlot(recipeId: 'r1', servings: 2),
          ),
        },
      );
      await repo.upsertWeekPlan(plan);

      final found = await repo.findByWeekKey('2025-W14');
      expect(found, equals(plan));
      expect(await repo.findByWeekKey('2025-W99'), isNull);
    });

    test('upsert replaces existing weekKey', () async {
      await repo.upsertWeekPlan(WeekPlan(weekKey: '2025-W14'));
      await repo.upsertWeekPlan(WeekPlan(
        weekKey: '2025-W14',
        days: {'tue': DayPlan(lunch: MealSlot(recipeId: 'r5'))},
      ));

      final items = await repo.readAll();
      expect(items.length, 1);
      expect(items.first.days.containsKey('tue'), isTrue);
    });

    test('deleteWeekPlan removes by weekKey', () async {
      await repo.upsertWeekPlan(WeekPlan(weekKey: '2025-W14'));
      expect(await repo.deleteWeekPlan('2025-W14'), isTrue);
      expect(await repo.readAll(), isEmpty);
    });
  });

  // ── GeneralItemRepository ─────────────────────────────────────────

  group('GeneralItemRepository', () {
    late GeneralItemRepository repo;

    setUp(() {
      repo = GeneralItemRepository(storage: testStorage(tmpDir));
    });

    test('readAll returns empty list when file does not exist', () async {
      expect(await repo.readAll(), isEmpty);
    });

    test('upsertItem + deleteItem', () async {
      final item = GeneralItem(id: 'g1', name: 'Küchenpapier');
      await repo.upsertItem(item);

      var items = await repo.readAll();
      expect(items.length, 1);

      await repo.deleteItem('g1');
      items = await repo.readAll();
      expect(items, isEmpty);
    });

    test('upsertItem updates existing', () async {
      await repo.upsertItem(GeneralItem(id: 'g1', name: 'Alt'));
      await repo.upsertItem(GeneralItem(id: 'g1', name: 'Neu'));

      final items = await repo.readAll();
      expect(items.length, 1);
      expect(items.first.name, 'Neu');
    });
  });

  // ── Edge cases ────────────────────────────────────────────────────

  group('Edge cases', () {
    test('corrupt JSON file returns empty list', () async {
      final file = File('${tmpDir.path}/recipes.json');
      await file.writeAsString('NOT VALID JSON!!!');

      final repo = RecipeRepository(storage: testStorage(tmpDir));
      expect(await repo.readAll(), isEmpty);
    });

    test('empty file returns empty list', () async {
      final file = File('${tmpDir.path}/recipes.json');
      await file.writeAsString('');

      final repo = RecipeRepository(storage: testStorage(tmpDir));
      expect(await repo.readAll(), isEmpty);
    });
  });
}
