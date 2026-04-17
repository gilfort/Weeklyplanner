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
String _$storageBackendHash() => r'adb128236fad5c747104935dffcc5f82a4f233fb';

/// Creates the correct [StorageBackend] based on the current platform and
/// user-configured [StorageConfig]. Async because the WebDAV branch needs
/// to read the password from secure storage.
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
String _$shoppingStateRepositoryHash() =>
    r'a9ed123036fd750d8201125422e508a23be461c6';

/// See also [shoppingStateRepository].
@ProviderFor(shoppingStateRepository)
final shoppingStateRepositoryProvider =
    AutoDisposeFutureProvider<ShoppingStateRepository>.internal(
      shoppingStateRepository,
      name: r'shoppingStateRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$shoppingStateRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShoppingStateRepositoryRef =
    AutoDisposeFutureProviderRef<ShoppingStateRepository>;
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
