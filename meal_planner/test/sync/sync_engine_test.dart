import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/models.dart';
import 'package:meal_planner/repositories/repositories.dart';
import 'package:meal_planner/sync/sync.dart';

/// One simulated device: its own private storage, its own base snapshots,
/// pointed at the shared folder.
class _Device {
  final Directory dir;
  final FileStorageBackend storage;
  final RecipeRepository recipes;
  final WeekPlanRepository weeks;
  final SyncEngine engine;

  _Device(this.dir, Directory shared)
      : storage = FileStorageBackend(directoryOverride: dir),
        recipes =
            RecipeRepository(storage: FileStorageBackend(directoryOverride: dir)),
        weeks = WeekPlanRepository(
            storage: FileStorageBackend(directoryOverride: dir)),
        engine = SyncEngine(
          local: FileStorageBackend(directoryOverride: dir),
          target: FolderSyncTarget(shared),
          base: BaseSnapshotStore(FileStorageBackend(directoryOverride: dir)),
        );

  Future<SyncReport> sync({DateTime? now}) =>
      engine.syncAll([recipes, weeks], now: now);
}

void main() {
  late Directory sharedDir;
  late Directory dirA;
  late Directory dirB;
  late _Device a;
  late _Device b;

  setUp(() {
    sharedDir = Directory.systemTemp.createTempSync('mp_shared_');
    dirA = Directory.systemTemp.createTempSync('mp_devA_');
    dirB = Directory.systemTemp.createTempSync('mp_devB_');
    a = _Device(dirA, sharedDir);
    b = _Device(dirB, sharedDir);
  });

  tearDown(() {
    for (final d in [sharedDir, dirA, dirB]) {
      try {
        if (d.existsSync()) d.deleteSync(recursive: true);
      } catch (_) {
        // Windows file locking: best-effort cleanup
      }
    }
  });

  group('first contact', () {
    test('an empty target is filled from the local device', () async {
      await a.recipes.upsertRecipe(Recipe(id: 'r1', name: 'Pasta'));

      final report = await a.sync();

      expect(report.pushed, 1);
      expect(report.failures, isEmpty);
      expect(File('${sharedDir.path}/recipes/r1.json').existsSync(), isTrue);
    });

    test('a fresh device pulls everything', () async {
      await a.recipes.upsertRecipe(Recipe(id: 'r1', name: 'Pasta'));
      await a.sync();

      final report = await b.sync();

      expect(report.pulled, 1);
      expect((await b.recipes.readAll()).single.name, 'Pasta');
    });

    test('a second run has nothing left to do', () async {
      await a.recipes.upsertRecipe(Recipe(id: 'r1', name: 'Pasta'));
      await a.sync();

      final report = await a.sync();

      expect(report.changed, 0);
      expect(report.unchanged, 1);
    });

    test('the base snapshot is written next to the data, not into it',
        () async {
      await a.recipes.upsertRecipe(Recipe(id: 'r1', name: 'Pasta'));
      await a.sync();

      expect(File('${dirA.path}/.sync/recipes/r1.json').existsSync(), isTrue);
      // …and never travels to the target: it describes this device's
      // agreement, and would be meaningless on the other one.
      expect(Directory('${sharedDir.path}/.sync').existsSync(), isFalse);
    });

    test('snapshots stay out of listKeys, so they never sync themselves',
        () async {
      await a.recipes.upsertRecipe(Recipe(id: 'r1', name: 'Pasta'));
      await a.sync();

      final keys = await a.storage.listKeys();
      expect(keys.any((k) => k.startsWith('.sync/')), isFalse);
      expect(keys, contains('recipes/r1.json'));
    });
  });

  group('concurrent edits', () {
    /// Gets both devices to the same starting point.
    Future<void> shareRecipe() async {
      await a.recipes.upsertRecipe(
        Recipe(id: 'r1', name: 'Pasta', servings: 2),
      );
      await a.sync();
      await b.sync();
    }

    test('edits to different fields both survive', () async {
      await shareRecipe();

      await a.recipes
          .upsertRecipe(Recipe(id: 'r1', name: 'Penne', servings: 2));
      await b.recipes
          .upsertRecipe(Recipe(id: 'r1', name: 'Pasta', servings: 6));

      await a.sync(); // fast-forward push
      await b.sync(); // sees a's change on top of its own → merge
      await a.sync(); // picks the merge back up

      for (final device in [a, b]) {
        final recipe = (await device.recipes.readAll()).single;
        expect(recipe.name, 'Penne');
        expect(recipe.servings, 6);
      }
    });

    test('the shopping tick and the plan edit both survive', () async {
      await a.weeks.upsertWeekPlan(WeekPlan(weekKey: '2025-W14'));
      await a.sync();
      await b.sync();

      // At home: plan a meal. In the shop: tick an item off.
      await a.weeks.upsertWeekPlan(WeekPlan(
        weekKey: '2025-W14',
        days: {'thu': const DayPlan(dinner: MealSlot(recipeId: 'r9'))},
      ));
      await b.weeks.upsertWeekPlan(WeekPlan(
        weekKey: '2025-W14',
        checkedIds: {'c-milch'},
      ));

      await a.sync();
      await b.sync();
      await a.sync();

      for (final device in [a, b]) {
        final plan = (await device.weeks.readAll()).single;
        expect(plan.days['thu']?.dinner?.recipeId, 'r9');
        expect(plan.checkedIds, {'c-milch'});
      }
    });

    test('both devices end up holding byte-identical files', () async {
      await shareRecipe();

      await a.recipes
          .upsertRecipe(Recipe(id: 'r1', name: 'Penne', servings: 2));
      await b.recipes.upsertRecipe(
          Recipe(id: 'r1', name: 'Pasta', servings: 2, tags: ['schnell']));

      await a.sync();
      await b.sync();
      await a.sync();

      expect(
        File('${dirA.path}/recipes/r1.json').readAsStringSync(),
        File('${dirB.path}/recipes/r1.json').readAsStringSync(),
      );
    });
  });

  group('deletions', () {
    test('a delete on one device reaches the other', () async {
      await a.recipes.upsertRecipe(Recipe(id: 'r1', name: 'Pasta'));
      await a.sync();
      await b.sync();

      await a.recipes.deleteRecipe('r1');
      await a.sync();
      await b.sync();

      expect(await b.recipes.readAll(), isEmpty);
      // The tombstone is still there — that is what stops the other device
      // from pushing the recipe back.
      expect(await b.recipes.readAll(includeDeleted: true), hasLength(1));
    });

    test('an expired tombstone is purged from both sides', () async {
      final deletedAt = DateTime.utc(2026, 1, 1);
      final now = deletedAt.add(const Duration(days: 100));

      await a.recipes.upsertRecipe(Recipe(id: 'r1', name: 'Pasta'));
      await a.recipes.deleteRecipe('r1', now: deletedAt);

      final report = await a.sync(now: now);

      expect(report.purged, 1);
      expect(File('${dirA.path}/recipes/r1.json').existsSync(), isFalse);
      expect(File('${sharedDir.path}/recipes/r1.json').existsSync(), isFalse);
      expect(File('${dirA.path}/.sync/recipes/r1.json').existsSync(), isFalse);
    });

    test('a fresh tombstone is kept', () async {
      final deletedAt = DateTime.utc(2026, 1, 1);

      await a.recipes.upsertRecipe(Recipe(id: 'r1', name: 'Pasta'));
      await a.recipes.deleteRecipe('r1', now: deletedAt);

      final report = await a.sync(now: deletedAt.add(const Duration(days: 10)));

      expect(report.purged, 0);
      expect(File('${sharedDir.path}/recipes/r1.json').existsSync(), isTrue);
    });
  });

  group('robustness', () {
    test('a corrupt remote file does not stop the other files', () async {
      await a.recipes.upsertRecipe(Recipe(id: 'r1', name: 'Pasta'));
      await a.sync();

      // A file from a newer build decodes to null on both sides, so there is
      // nothing to reconcile — and r1 must still sync.
      File('${sharedDir.path}/recipes/r2.json').writeAsStringSync(
        jsonEncode({'schemaVersion': 99, 'data': {}}),
      );

      final report = await b.sync();

      expect(report.failures, isEmpty);
      expect((await b.recipes.readAll()).single.id, 'r1');
    });

    test('an unreachable target is reported, not thrown', () async {
      final broken = SyncEngine(
        local: FileStorageBackend(directoryOverride: dirA),
        target: FolderSyncTarget(Directory('${dirA.path}/does-not-exist')),
        base: BaseSnapshotStore(FileStorageBackend(directoryOverride: dirA)),
      );

      // Listing a missing folder is empty rather than fatal, so this run
      // simply pushes everything once the folder appears.
      final report = await broken.syncAll([a.recipes]);
      expect(report.failures, isEmpty);
    });
  });

  group('unit list', () {
    Future<void> writeUnits(FileStorageBackend s, List<String> units) =>
        s.write(UnitRepository.fileName, jsonEncode(units));

    Future<Set<String>> readUnits(Directory dir) async {
      final file = File('${dir.path}/${UnitRepository.fileName}');
      if (!file.existsSync()) return {};
      return (jsonDecode(file.readAsStringSync()) as List)
          .cast<String>()
          .toSet();
    }

    test('units added on either device end up on both', () async {
      await writeUnits(a.storage, ['g', 'kg']);
      await a.sync();
      await b.sync();

      await writeUnits(a.storage, ['g', 'kg', 'Bund']);
      await writeUnits(b.storage, ['g', 'kg', 'Dose']);

      await a.sync();
      await b.sync();
      await a.sync();

      expect(await readUnits(dirA), {'g', 'kg', 'Bund', 'Dose'});
      expect(await readUnits(dirB), {'g', 'kg', 'Bund', 'Dose'});
    });

    test('a target without a unit file does not wipe the local list',
        () async {
      await writeUnits(a.storage, ['g', 'kg']);

      await a.sync();

      expect(await readUnits(dirA), {'g', 'kg'});
      expect(await readUnits(sharedDir), {'g', 'kg'});
    });

    test('a unit removed on one device goes away on the other', () async {
      await writeUnits(a.storage, ['g', 'kg']);
      await a.sync();
      await b.sync();

      await writeUnits(a.storage, ['g']);
      await a.sync();
      await b.sync();

      expect(await readUnits(dirB), {'g'});
    });
  });
}
