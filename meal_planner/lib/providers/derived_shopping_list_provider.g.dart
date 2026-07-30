// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'derived_shopping_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$derivedShoppingListHash() =>
    r'4330551390569561586c3d1c5edb3de2e2246cc0';

/// Pure derived provider — no own state.
/// Aggregates scaled recipe ingredients from the active week plan,
/// merges general items (minus the ones excluded this week), applies
/// per-week amount overrides, and appends week-scoped quick-add items.
///
/// Copied from [derivedShoppingList].
@ProviderFor(derivedShoppingList)
final derivedShoppingListProvider =
    AutoDisposeFutureProvider<List<ShoppingItem>>.internal(
      derivedShoppingList,
      name: r'derivedShoppingListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$derivedShoppingListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DerivedShoppingListRef =
    AutoDisposeFutureProviderRef<List<ShoppingItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
