// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storageBackendHash() => r'67ae6e66a13d5bb020003b689edb1e142f0c1211';

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
///
/// Copied from [storageBackend].
@ProviderFor(storageBackend)
final storageBackendProvider = AutoDisposeProvider<StorageBackend>.internal(
  storageBackend,
  name: r'storageBackendProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storageBackendHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StorageBackendRef = AutoDisposeProviderRef<StorageBackend>;
String _$recipeRepositoryHash() => r'd2f112ef6cf0562e00e9bfd436e80510f0d38dc6';

/// See also [recipeRepository].
@ProviderFor(recipeRepository)
final recipeRepositoryProvider = AutoDisposeProvider<RecipeRepository>.internal(
  recipeRepository,
  name: r'recipeRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recipeRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecipeRepositoryRef = AutoDisposeProviderRef<RecipeRepository>;
String _$weekPlanRepositoryHash() =>
    r'9661098733c5586a2f2d77e40515abfbae6408e6';

/// See also [weekPlanRepository].
@ProviderFor(weekPlanRepository)
final weekPlanRepositoryProvider =
    AutoDisposeProvider<WeekPlanRepository>.internal(
      weekPlanRepository,
      name: r'weekPlanRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$weekPlanRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeekPlanRepositoryRef = AutoDisposeProviderRef<WeekPlanRepository>;
String _$generalItemRepositoryHash() =>
    r'abce0e370514b767e34d83edc110bc399d4e40eb';

/// See also [generalItemRepository].
@ProviderFor(generalItemRepository)
final generalItemRepositoryProvider =
    AutoDisposeProvider<GeneralItemRepository>.internal(
      generalItemRepository,
      name: r'generalItemRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$generalItemRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GeneralItemRepositoryRef =
    AutoDisposeProviderRef<GeneralItemRepository>;
String _$ingredientCatalogRepositoryHash() =>
    r'968ebcb094ffe23a0bf1295ff5c64c32d64e5912';

/// See also [ingredientCatalogRepository].
@ProviderFor(ingredientCatalogRepository)
final ingredientCatalogRepositoryProvider =
    AutoDisposeProvider<IngredientCatalogRepository>.internal(
      ingredientCatalogRepository,
      name: r'ingredientCatalogRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ingredientCatalogRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IngredientCatalogRepositoryRef =
    AutoDisposeProviderRef<IngredientCatalogRepository>;
String _$unitRepositoryHash() => r'b745e487d1a184b5ff2a02b6b67ebde8d1751cd8';

/// See also [unitRepository].
@ProviderFor(unitRepository)
final unitRepositoryProvider = AutoDisposeProvider<UnitRepository>.internal(
  unitRepository,
  name: r'unitRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unitRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnitRepositoryRef = AutoDisposeProviderRef<UnitRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
