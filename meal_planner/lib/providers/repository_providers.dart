import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/repositories.dart';
import '../services/webdav_credentials_service.dart';
import 'storage_config_provider.dart';

part 'repository_providers.g.dart';

@riverpod
WebDavCredentialsService webdavCredentialsService(
    WebdavCredentialsServiceRef ref) {
  return WebDavCredentialsService();
}

/// Creates the correct [StorageBackend] based on the current platform and
/// user-configured [StorageConfig]. Async because the WebDAV branch needs
/// to read the password from secure storage.
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
      return FileStorageBackend(directoryOverride: Directory(config.path!));
    case StorageType.local:
      return FileStorageBackend();
  }
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
