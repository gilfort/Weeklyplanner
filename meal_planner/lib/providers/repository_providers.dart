import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/repositories.dart';
import 'google_drive_provider.dart';
import 'storage_mode_provider.dart';
import 'storage_path_provider.dart';

part 'repository_providers.g.dart';

/// Builds the [StorageBackend] appropriate to the platform + user config.
///
/// Selection order:
///   - Web            → [WebStorageBackend]
///   - Drive mode ✓   → [CachedSyncStorageBackend] (local cache + Drive)
///   - Local mode     → [FileStorageBackend] (custom path optional)
///
/// If Drive mode is selected but the user has not yet signed in or picked
/// a folder, we fall back to the local file backend so the app stays usable;
/// the Settings screen prompts the user to finish setup.
@riverpod
StorageBackend storageBackend(StorageBackendRef ref) {
  if (kIsWeb) {
    return WebStorageBackend();
  }

  final mode =
      ref.watch(currentStorageModeProvider).valueOrNull ?? StorageMode.local;

  if (mode == StorageMode.googleDrive) {
    final signInAsync = ref.watch(signInProvider);
    // Auto-kick the silent Google sign-in on cold start. `SignIn.build()` is
    // idle; without this trigger Drive mode would stay stuck on local-only
    // until the user opens the Settings screen.
    if (signInAsync is AsyncData && signInAsync.value == null) {
      Future.microtask(
        () => ref.read(signInProvider.notifier).ensureInitialized(),
      );
    }
    final account = signInAsync.valueOrNull;
    final folder = ref.watch(driveFolderProvider).valueOrNull;
    if (account != null && folder != null) {
      final auth = ref.watch(googleAuthServiceProvider);
      return CachedSyncStorageBackend(
        local: FileStorageBackend(),
        remote: GoogleDriveStorageBackend(
          auth: auth,
          folderId: folder.folderId,
        ),
      );
    }
    // Not fully configured yet — local cache only.
    return FileStorageBackend();
  }

  // Local mode
  final customPath = ref.watch(storagePathProvider).valueOrNull;
  if (customPath != null && customPath.isNotEmpty) {
    return FileStorageBackend(directoryOverride: Directory(customPath));
  }
  return FileStorageBackend();
}

@riverpod
RecipeRepository recipeRepository(RecipeRepositoryRef ref) {
  return RecipeRepository(storage: ref.watch(storageBackendProvider));
}

@riverpod
WeekPlanRepository weekPlanRepository(WeekPlanRepositoryRef ref) {
  return WeekPlanRepository(storage: ref.watch(storageBackendProvider));
}

@riverpod
GeneralItemRepository generalItemRepository(GeneralItemRepositoryRef ref) {
  return GeneralItemRepository(storage: ref.watch(storageBackendProvider));
}

@riverpod
IngredientCatalogRepository ingredientCatalogRepository(
    IngredientCatalogRepositoryRef ref) {
  return IngredientCatalogRepository(
      storage: ref.watch(storageBackendProvider));
}

@riverpod
UnitRepository unitRepository(UnitRepositoryRef ref) {
  return UnitRepository(storage: ref.watch(storageBackendProvider));
}
