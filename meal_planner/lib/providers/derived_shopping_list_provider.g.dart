// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'derived_shopping_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$derivedShoppingListHash() =>
    r'17994cea2739f206cca0fcfea34ca45c585c7eef';

/// Pure derived provider — no own state.
///
/// Every contribution to an ingredient collapses onto one line keyed by its
/// catalog id: scaled recipe ingredients, the general list (minus what this
/// week excludes) and the week's quick-adds. Amounts in compatible units are
/// summed, incompatible ones stay side by side. Per-week overrides replace a
/// line's amounts entirely.
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
