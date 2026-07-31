import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/repositories.dart';
import '../services/webdav_credentials_service.dart';
import '../sync/sync.dart';
import 'storage_config_provider.dart';

part 'repository_providers.g.dart';

@riverpod
WebDavCredentialsService webdavCredentialsService(
    WebdavCredentialsServiceRef ref) {
  return WebDavCredentialsService();
}

/// Lets the storage layer poke the sync service without depending on it —
/// the service binds itself here once it exists, which keeps the providers
/// from forming a cycle.
class SyncTrigger {
  void Function()? _onWrite;

  void bind(void Function() onWrite) => _onWrite = onWrite;
  void unbind() => _onWrite = null;
  void fire() => _onWrite?.call();
}

@Riverpod(keepAlive: true)
SyncTrigger syncTrigger(SyncTriggerRef ref) => SyncTrigger();

/// Creates the correct [StorageBackend] based on the current platform and
/// user-configured [StorageConfig]. Async because the WebDAV branch needs
/// to read the password from secure storage.
///
/// App data always lives in private storage; a sync target is reconciled on
/// top of it. The folder case is already on the new engine — SAF and WebDAV
/// still ride the old cached backend until phases 4 and 5 replace them.
@riverpod
Future<StorageBackend> storageBackend(StorageBackendRef ref) async {
  if (kIsWeb) {
    return WebStorageBackend();
  }

  final config = await ref.watch(storageConfigNotifierProvider.future);

  switch (config.type) {
    case StorageType.saf:
      final local = FileStorageBackend();
      final remote = SafStorageBackend(treeUri: config.safUri!);
      return CachedSyncStorageBackend(local: local, remote: remote);
    case StorageType.webdav:
      final pw =
          await ref.read(webdavCredentialsServiceProvider).read(config);
      if (pw == null) {
        throw StateError('WebDAV password missing for ${config.webdavUrl}');
      }
      final local = FileStorageBackend();
      final remote = WebDavStorageBackend(
        baseUrl: config.webdavUrl!,
        username: config.webdavUsername!,
        password: pw,
        pathPrefix: config.webdavPathPrefix ?? '/MealPlanner',
      );
      return CachedSyncStorageBackend(local: local, remote: remote);
    case StorageType.filesystem:
    case StorageType.local:
      return NotifyingStorageBackend(
        inner: FileStorageBackend(),
        onWrite: ref.read(syncTriggerProvider).fire,
      );
  }
}

/// The engine for the folder target, or null when no folder is configured.
@riverpod
Future<SyncEngine?> syncEngine(SyncEngineRef ref) async {
  final config = await ref.watch(storageConfigNotifierProvider.future);
  if (config.type != StorageType.filesystem || config.path == null) {
    return null;
  }
  final backend = await ref.watch(storageBackendProvider.future);
  if (backend is! SyncableStorageBackend) return null;

  return SyncEngine(
    local: backend,
    target: FolderSyncTarget(Directory(config.path!)),
    base: BaseSnapshotStore(backend),
  );
}

@riverpod
Future<RecipeRepository> recipeRepository(RecipeRepositoryRef ref) async {
  return RecipeRepository(storage: await ref.watch(storageBackendProvider.future));
}

@riverpod
Future<WeekPlanRepository> weekPlanRepository(WeekPlanRepositoryRef ref) async {
  return WeekPlanRepository(
      storage: await ref.watch(storageBackendProvider.future));
}

@riverpod
Future<GeneralItemRepository> generalItemRepository(
    GeneralItemRepositoryRef ref) async {
  return GeneralItemRepository(
      storage: await ref.watch(storageBackendProvider.future));
}

@riverpod
Future<IngredientCatalogRepository> ingredientCatalogRepository(
    IngredientCatalogRepositoryRef ref) async {
  return IngredientCatalogRepository(
      storage: await ref.watch(storageBackendProvider.future));
}

@riverpod
Future<UnitRepository> unitRepository(UnitRepositoryRef ref) async {
  return UnitRepository(storage: await ref.watch(storageBackendProvider.future));
}
