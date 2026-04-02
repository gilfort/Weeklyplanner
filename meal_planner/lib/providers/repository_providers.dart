import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/repositories.dart';
import 'storage_path_provider.dart';

part 'repository_providers.g.dart';

/// Creates the correct [StorageBackend] based on the current platform.
/// On native platforms, watches [storagePathProvider] so that when the user
/// changes the storage directory in Settings, all repositories rebuild.
@riverpod
StorageBackend storageBackend(StorageBackendRef ref) {
  if (kIsWeb) {
    return WebStorageBackend();
  }
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
ShoppingStateRepository shoppingStateRepository(
    ShoppingStateRepositoryRef ref) {
  return ShoppingStateRepository(storage: ref.watch(storageBackendProvider));
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
