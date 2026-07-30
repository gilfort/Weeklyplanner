import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/cached_sync_storage_backend.dart';
import '../services/sync_service.dart';
import 'repository_providers.dart';

part 'sync_provider.g.dart';

/// Creates and manages the [SyncService] when a [CachedSyncStorageBackend] is
/// active. Returns null for local/filesystem backends. Async because the
/// underlying storageBackendProvider is async (WebDAV credentials lookup).
@Riverpod(keepAlive: true)
Future<SyncService?> syncService(SyncServiceRef ref) async {
  final backend = await ref.watch(storageBackendProvider.future);
  if (backend is! CachedSyncStorageBackend) return null;

  final service = SyncService(backend: backend);
  ref.onDispose(service.dispose);

  // Initial sync + start periodic timer.
  service.syncAll();
  service.startPeriodicSync();

  return service;
}

/// Exposes sync status as a stream for UI consumption.
@riverpod
Stream<SyncStatusDetail> syncStatus(SyncStatusRef ref) async* {
  final service = await ref.watch(syncServiceProvider.future);
  if (service == null) {
    yield SyncStatusDetail(SyncStatus.idle);
    return;
  }
  yield* service.status;
}
