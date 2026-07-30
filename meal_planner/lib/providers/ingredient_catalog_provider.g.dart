// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_catalog_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$catalogByIdHash() => r'dc7a154c0fd9631113c7b367938149724a5d0f31';

/// Catalog entries by id, for the many places that need to turn an id back
/// into a display name.
///
/// Copied from [catalogById].
@ProviderFor(catalogById)
final catalogByIdProvider =
    AutoDisposeFutureProvider<Map<String, IngredientCatalogEntry>>.internal(
      catalogById,
      name: r'catalogByIdProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$catalogByIdHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CatalogByIdRef =
    AutoDisposeFutureProviderRef<Map<String, IngredientCatalogEntry>>;
String _$ingredientCatalogHash() => r'b513bd4db9b87945d49850b77c3be1443aa68320';

/// The catalog owns ingredient identity. Everything that refers to an
/// ingredient — recipe lines, general items, the week's checked-off state —
/// stores a catalog id, so renaming an ingredient never orphans anything.
///
/// Copied from [IngredientCatalog].
@ProviderFor(IngredientCatalog)
final ingredientCatalogProvider =
    AsyncNotifierProvider<
      IngredientCatalog,
      List<IngredientCatalogEntry>
    >.internal(
      IngredientCatalog.new,
      name: r'ingredientCatalogProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ingredientCatalogHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$IngredientCatalog = AsyncNotifier<List<IngredientCatalogEntry>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
