// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$webdavCredentialsServiceHash() =>
    r'cb7cf33b88d90b00e69af3849722ec28711919fa';

/// See also [webdavCredentialsService].
@ProviderFor(webdavCredentialsService)
final webdavCredentialsServiceProvider =
    AutoDisposeProvider<WebDavCredentialsService>.internal(
      webdavCredentialsService,
      name: r'webdavCredentialsServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$webdavCredentialsServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WebdavCredentialsServiceRef =
    AutoDisposeProviderRef<WebDavCredentialsService>;
String _$syncTriggerHash() => r'e5a2721800cdfd261d079c4f7f915be223dcf88c';

/// See also [syncTrigger].
@ProviderFor(syncTrigger)
final syncTriggerProvider = Provider<SyncTrigger>.internal(
  syncTrigger,
  name: r'syncTriggerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncTriggerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncTriggerRef = ProviderRef<SyncTrigger>;
String _$storageBackendHash() => r'bffd2dbd103eda2f9e2806201a3576ee17752707';

/// Creates the correct [StorageBackend] based on the current platform and
/// user-configured [StorageConfig]. Async because the WebDAV branch needs
/// to read the password from secure storage.
///
/// App data always lives in private storage; a sync target is reconciled on
/// top of it. The folder case is already on the new engine — SAF and WebDAV
/// still ride the old cached backend until phases 4 and 5 replace them.
///
/// Copied from [storageBackend].
@ProviderFor(storageBackend)
final storageBackendProvider =
    AutoDisposeFutureProvider<StorageBackend>.internal(
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
typedef StorageBackendRef = AutoDisposeFutureProviderRef<StorageBackend>;
String _$syncEngineHash() => r'f0414960cb9baf74b6b7980e95c2f5b76f29b85f';

/// The engine for the folder target, or null when no folder is configured.
///
/// Copied from [syncEngine].
@ProviderFor(syncEngine)
final syncEngineProvider = AutoDisposeFutureProvider<SyncEngine?>.internal(
  syncEngine,
  name: r'syncEngineProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncEngineHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncEngineRef = AutoDisposeFutureProviderRef<SyncEngine?>;
String _$recipeRepositoryHash() => r'bfb995fe6de3a712a8ea2955785b07d6f126fcb5';

/// See also [recipeRepository].
@ProviderFor(recipeRepository)
final recipeRepositoryProvider =
    AutoDisposeFutureProvider<RecipeRepository>.internal(
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
typedef RecipeRepositoryRef = AutoDisposeFutureProviderRef<RecipeRepository>;
String _$weekPlanRepositoryHash() =>
    r'7d870648b0dc1b4d0d2ea5b282b496c76dd6f24f';

/// See also [weekPlanRepository].
@ProviderFor(weekPlanRepository)
final weekPlanRepositoryProvider =
    AutoDisposeFutureProvider<WeekPlanRepository>.internal(
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
typedef WeekPlanRepositoryRef =
    AutoDisposeFutureProviderRef<WeekPlanRepository>;
String _$generalItemRepositoryHash() =>
    r'26d6a227b4fc6157104de53d065b3b99cb53fc30';

/// See also [generalItemRepository].
@ProviderFor(generalItemRepository)
final generalItemRepositoryProvider =
    AutoDisposeFutureProvider<GeneralItemRepository>.internal(
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
    AutoDisposeFutureProviderRef<GeneralItemRepository>;
String _$ingredientCatalogRepositoryHash() =>
    r'3adfbf3e94e81c4ec08ab91e46e6f3eb8b9aec54';

/// See also [ingredientCatalogRepository].
@ProviderFor(ingredientCatalogRepository)
final ingredientCatalogRepositoryProvider =
    AutoDisposeFutureProvider<IngredientCatalogRepository>.internal(
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
    AutoDisposeFutureProviderRef<IngredientCatalogRepository>;
String _$unitRepositoryHash() => r'edc95f0f673b128d8e42359a283b72233f30cd4f';

/// See also [unitRepository].
@ProviderFor(unitRepository)
final unitRepositoryProvider =
    AutoDisposeFutureProvider<UnitRepository>.internal(
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
typedef UnitRepositoryRef = AutoDisposeFutureProviderRef<UnitRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
