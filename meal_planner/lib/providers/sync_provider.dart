import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/cached_sync_storage_backend.dart';
import '../services/sync_service.dart';
import '../sync/sync_engine.dart';
import 'general_items_provider.dart';
import 'ingredient_catalog_provider.dart';
import 'recipe_provider.dart';
import 'repository_providers.dart';
import 'unit_provider.dart';
import 'week_plan_provider.dart';

part 'sync_provider.g.dart';

/// Creates and manages the [SyncService] for whichever target is configured.
/// Returns null when there is nothing to sync with (local-only storage).
@Riverpod(keepAlive: true)
Future<SyncService?> syncService(SyncServiceRef ref) async {
  final cycle = await _cycleFor(ref);
  if (cycle == null) return null;

  final service = SyncService(cycle: cycle);
  final trigger = ref.read(syncTriggerProvider);
  trigger.bind(service.scheduleSync);

  ref.onDispose(() {
    trigger.unbind();
    service.dispose();
  });

  // Pull on start; from here on it is resume, debounced writes and manual
  // refresh — no timers, per the foreground-only design.
  service.syncNow();

  return service;
}

Future<SyncCycle?> _cycleFor(SyncServiceRef ref) async {
  final engine = await ref.watch(syncEngineProvider.future);
  if (engine != null) {
    return () async {
      final report = await engine.syncAll([
        await ref.read(recipeRepositoryProvider.future),
        await ref.read(weekPlanRepositoryProvider.future),
        await ref.read(generalItemRepositoryProvider.future),
        await ref.read(ingredientCatalogRepositoryProvider.future),
      ]);
      // Anything the engine pulled or merged is on disk but not yet in the
      // providers holding the UI's copy.
      if (report.changed > 0) _invalidateData(ref);
      return report;
    };
  }

  // Legacy path for SAF and WebDAV until phases 4 and 5 land.
  final backend = await ref.watch(storageBackendProvider.future);
  if (backend is! CachedSyncStorageBackend) return null;
  return () async {
    await backend.syncAll();
    _invalidateData(ref);
    return const SyncReport();
  };
}

void _invalidateData(SyncServiceRef ref) {
  ref.invalidate(recipesProvider);
  ref.invalidate(generalItemsProvider);
  ref.invalidate(ingredientCatalogProvider);
  ref.invalidate(unitsProvider);
  ref.invalidate(weekPlanNotifierProvider);
}

/// Exposes sync status as a stream for UI consumption.
@riverpod
Stream<SyncStatusDetail> syncStatus(SyncStatusRef ref) async* {
  final service = await ref.watch(syncServiceProvider.future);
  if (service == null) {
    yield const SyncStatusDetail(SyncStatus.idle);
    return;
  }
  yield* service.status;
}
