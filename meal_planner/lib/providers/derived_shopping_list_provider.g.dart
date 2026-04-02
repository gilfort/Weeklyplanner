// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'derived_shopping_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$derivedShoppingListHash() =>
    r'adae340131842c83a902a4823c70bb494001b305';

/// Pure derived provider — no own state.
/// Aggregates scaled recipe ingredients from the active week plan
/// and combines them with general items into a unified shopping list.
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
