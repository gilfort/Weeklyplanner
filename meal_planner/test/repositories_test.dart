import 'dart:convert';
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

    test('readAll returns empty list when nothing was written', () async {
      final items = await repo.readAll();
      expect(items, isEmpty);
    });

    test('writes one file per recipe', () async {
      await repo.upsertRecipe(Recipe(id: 'r1', name: 'Pasta'));
      await repo.upsertRecipe(Recipe(id: 'r2', name: 'Salat'));

      final files = Directory('${tmpDir.path}/recipes')
          .listSync()
          .map((f) => f.uri.pathSegments.last)
          .toList();
      expect(files, containsAll(['r1.json', 'r2.json']));
    });

    test('every file carries the schema version', () async {
      await repo.upsertRecipe(Recipe(id: 'r1', name: 'Pasta'));

      final raw = File('${tmpDir.path}/recipes/r1.json').readAsStringSync();
      final envelope = jsonDecode(raw) as Map<String, dynamic>;
      expect(envelope['schemaVersion'], kSchemaVersion);
      expect((envelope['data'] as Map)['name'], 'Pasta');
    });

    test('upsertRecipe inserts and updates', () async {
      final recipe = Recipe(id: 'r1', name: 'Pasta', servings: 2);
      await repo.upsertRecipe(recipe);

      var items = await repo.readAll();
      expect(items.length, 1);
      expect(items.first.name, 'Pasta');

      await repo.upsertRecipe(recipe.copyWith(name: 'Penne'));
      items = await repo.readAll();
      expect(items.length, 1);
      expect(items.first.name, 'Penne');
    });

    test('deleteRecipe soft-deletes and hides the recipe', () async {
      await repo.upsertRecipe(Recipe(id: 'r1', name: 'Pasta'));
      await repo.upsertRecipe(Recipe(id: 'r2', name: 'Salat'));

      expect(await repo.deleteRecipe('r1'), isTrue);

      final visible = await repo.readAll();
      expect(visible.map((r) => r.id), ['r2']);

      // The tombstone stays on disk so other devices learn about the delete.
      expect(File('${tmpDir.path}/recipes/r1.json').existsSync(), isTrue);
      final all = await repo.readAll(includeDeleted: true);
      expect(all.length, 2);
      expect(all.firstWhere((r) => r.id == 'r1').deleted, isTrue);
    });

    test('deleteRecipe returns false for unknown id', () async {
      expect(await repo.deleteRecipe('nope'), isFalse);
    });

    test('findById returns item or null, ignoring tombstones', () async {
      await repo.upsertRecipe(Recipe(id: 'r1', name: 'Pasta'));
      expect((await repo.findById('r1'))?.name, 'Pasta');
      expect(await repo.findById('nope'), isNull);

      await repo.deleteRecipe('r1');
      expect(await repo.findById('r1'), isNull);
      expect((await repo.findById('r1', includeDeleted: true))?.deleted, isTrue);
    });

    test('rejects ids that are not safe as file names', () async {
      expect(
        () => repo.upsertRecipe(Recipe(id: '../escape', name: 'Böse')),
        throwsArgumentError,
      );
    });
  });

  // ── Tombstone purging ─────────────────────────────────────────────

  group('purgeTombstones', () {
    late RecipeRepository repo;
    final now = DateTime.utc(2026, 6, 1);

    setUp(() {
      repo = RecipeRepository(storage: testStorage(tmpDir));
    });

    test('removes tombstones older than the retention window', () async {
      await repo.upsertRecipe(Recipe(id: 'old', name: 'Alt'));
      await repo.upsertRecipe(Recipe(id: 'fresh', name: 'Neu'));
      await repo.deleteRecipe('old',
          now: now.subtract(const Duration(days: 100)));
      await repo.deleteRecipe('fresh',
          now: now.subtract(const Duration(days: 10)));

      final removed = await repo.purgeTombstones(now: now);

      expect(removed, 1);
      expect(File('${tmpDir.path}/recipes/old.json').existsSync(), isFalse);
      expect(File('${tmpDir.path}/recipes/fresh.json').existsSync(), isTrue);
    });

    test('never touches live entities', () async {
      await repo.upsertRecipe(Recipe(id: 'r1', name: 'Pasta'));

      expect(await repo.purgeTombstones(now: now), 0);
      expect(await repo.readAll(), hasLength(1));
    });
  });

  // ── WeekPlanRepository ────────────────────────────────────────────

  group('WeekPlanRepository', () {
    late WeekPlanRepository repo;

    setUp(() {
      repo = WeekPlanRepository(storage: testStorage(tmpDir));
    });

    test('readAll returns empty list when nothing was written', () async {
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

    test('one week per file, so two weeks never conflict', () async {
      await repo.upsertWeekPlan(WeekPlan(weekKey: '2025-W14'));
      await repo.upsertWeekPlan(WeekPlan(weekKey: '2025-W15'));

      expect(File('${tmpDir.path}/weeks/2025-W14.json').existsSync(), isTrue);
      expect(File('${tmpDir.path}/weeks/2025-W15.json').existsSync(), isTrue);
    });

    test('deleteWeekPlan hides the plan', () async {
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

    test('readAll returns empty list when nothing was written', () async {
      expect(await repo.readAll(), isEmpty);
    });

    test('upsertItem + deleteItem', () async {
      const item = GeneralItem(catalogId: 'c-papier');
      await repo.upsertItem(item);

      expect(await repo.readAll(), hasLength(1));

      await repo.deleteItem('c-papier');
      expect(await repo.readAll(), isEmpty);
    });

    test('upsertItem updates existing', () async {
      await repo.upsertItem(const GeneralItem(catalogId: 'c1', amount: 1));
      await repo.upsertItem(const GeneralItem(catalogId: 'c1', amount: 5));

      final items = await repo.readAll();
      expect(items.length, 1);
      expect(items.first.amount, 5);
    });
  });

  // ── IngredientCatalogRepository ───────────────────────────────────

  group('IngredientCatalogRepository', () {
    test('renaming keeps the entry id', () async {
      final repo = IngredientCatalogRepository(storage: testStorage(tmpDir));
      await repo.upsertEntry(
        const IngredientCatalogEntry(id: 'c1', name: 'Mehl'),
      );
      await repo.upsertEntry(
        const IngredientCatalogEntry(id: 'c1', name: 'Weizenmehl'),
      );

      final entries = await repo.readAll();
      expect(entries, hasLength(1));
      expect(entries.single.id, 'c1');
      expect(entries.single.name, 'Weizenmehl');
    });
  });

  // ── Edge cases ────────────────────────────────────────────────────

  group('Edge cases', () {
    test('corrupt entity file is skipped, others still load', () async {
      final repo = RecipeRepository(storage: testStorage(tmpDir));
      await repo.upsertRecipe(Recipe(id: 'good', name: 'Pasta'));

      File('${tmpDir.path}/recipes/broken.json')
          .writeAsStringSync('NOT VALID JSON!!!');

      final items = await repo.readAll();
      expect(items.map((r) => r.id), ['good']);
    });

    test('empty file is skipped', () async {
      final repo = RecipeRepository(storage: testStorage(tmpDir));
      Directory('${tmpDir.path}/recipes').createSync(recursive: true);
      File('${tmpDir.path}/recipes/empty.json').writeAsStringSync('');

      expect(await repo.readAll(), isEmpty);
    });

    test('a file from a future schema version is left alone', () async {
      final repo = RecipeRepository(storage: testStorage(tmpDir));
      Directory('${tmpDir.path}/recipes').createSync(recursive: true);
      final future = File('${tmpDir.path}/recipes/r9.json')
        ..writeAsStringSync(jsonEncode({
          'schemaVersion': kSchemaVersion + 1,
          'data': {'id': 'r9', 'name': 'Aus der Zukunft'},
        }));

      expect(await repo.readAll(), isEmpty);
      expect(future.existsSync(), isTrue);
    });
  });

  // ── FileStorageBackend ────────────────────────────────────────────

  group('FileStorageBackend', () {
    test('write creates parent directories', () async {
      final storage = testStorage(tmpDir);
      await storage.write('deep/nested/file.json', '{}');

      expect(File('${tmpDir.path}/deep/nested/file.json').existsSync(), isTrue);
    });

    test('write leaves no temp file behind', () async {
      final storage = testStorage(tmpDir);
      await storage.write('recipes/r1.json', '{}');

      final names = Directory('${tmpDir.path}/recipes')
          .listSync()
          .map((f) => f.uri.pathSegments.last);
      expect(names, ['r1.json']);
    });

    test('list returns bare names of one directory only', () async {
      final storage = testStorage(tmpDir);
      await storage.write('recipes/r1.json', '{}');
      await storage.write('weeks/w1.json', '{}');

      expect(await storage.list('recipes'), ['r1.json']);
      expect(await storage.list('nope'), isEmpty);
    });

    test('listKeys walks sub-directories and returns posix paths', () async {
      final storage = testStorage(tmpDir);
      await storage.write('recipes/r1.json', '{}');
      await storage.write('weeks/2025-W14.json', '{}');

      final keys = await storage.listKeys();
      expect(keys, containsAll(['recipes/r1.json', 'weeks/2025-W14.json']));
    });

    test('delete removes the file and is a no-op when missing', () async {
      final storage = testStorage(tmpDir);
      await storage.write('recipes/r1.json', '{}');

      await storage.delete('recipes/r1.json');
      expect(File('${tmpDir.path}/recipes/r1.json').existsSync(), isFalse);
      await storage.delete('recipes/r1.json');
    });
  });
}
